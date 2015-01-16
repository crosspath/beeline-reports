require 'csv'

class UserFile < ActiveRecord::Base
  belongs_to :subscriber

  STORAGE = File.realpath(Rails.root.join('files').to_s)
  CSV_OPTIONS = {col_sep: ';', skip_blanks: true, converters: :float_comma}
  ENCODING = 'windows-1251'

  if File.exists?(STORAGE)
    raise "#{STORAGE} should be directory, but it is a file" unless File.directory?(STORAGE)
  else
    Dir.mkdir(STORAGE, 0755)
  end

  CSV::Converters[:float_comma] = lambda { |x|
    if x =~ /^\d*([.,]\d+)?/
      $1.present? ? x.sub(',', '.').to_f : x.to_i
    else
      x
    end
  }

  class << self
    def upload(s)
      s = File.realpath(s)
      u = self.where(original_filename: s)
      raise "File #{s} is uploaded already: #{u.pluck(:original_filename).join(', ')}" if u.present?
      raise "File #{s} is not readable" unless File.readable?(s)
      raise "Directory #{STORAGE} is not writable" unless File.writable?(STORAGE)
      raise "File #{s} has not .csv extension" if File.extname(s).downcase != '.csv'

      u = self.create! original_filename: s
      File.copy_stream(s, u.filename)
      # TODO: добавить u.id в очередь обработки
      u
    end
  end

  def filename
    STORAGE + File::SEPARATOR + id.to_s + '.csv'
  end

  def import
    file = File.read(filename).force_encoding(ENCODING)
    file.gsub!('""', '')
    f = CSV.new(file, CSV_OPTIONS)
    subscriber = nil
    headers = nil
    headers_calls = nil
    h = lambda { |row, sym| row[headers[sym]] }
    f.each do |row|
      row = array_utf8(row)
      unless headers
        headers = init_headers_hash(row)
        headers_calls = headers.reject { |k, _| k.in?([:contract, :phone, :call_date, :call_time]) }
        next
      end
      subscriber ||= Subscriber.find_or_create_by(contract: h.call(row, :contract), phone: h.call(row, :phone))
      raise "Error in file #{filename}" if subscriber.nil? || headers_calls.blank?

      c = Call.new(subscriber_id: subscriber.id, call_date: "#{h.call(row, :call_date)} #{h.call(row, :call_time)}")
      headers_calls.each { |k, i| c.send("#{k}=", row[i]) }
      c.save!
      self.start_date ||= c.call_date
      self.end_date = c.call_date
    end
    self.subscriber = subscriber
    save!
    # TODO: добавить id в очередь результатов
  end

  def imported?
    # TODO: опросить очередь результатов, обработан ли файл с данным id
    # Временное решение:
    reload.subscriber.present?
  end

  protected

  def init_headers_hash(headers)
    ret = {}
    cols = {
        'Номер договора' => :contract, 'Номер абонента' => :phone, 'Дата звонка' => :call_date,
        'Время звонка' => :call_time, 'Длительность' => :length, 'Длительность округленная до минут' => :length_r,
        'Размер начислений' => :cost, 'Инициатор звонка' => :caller, 'Принимающий номер' => :receiver,
        'Описание действия' => :action, 'Описание услуги' => :service, 'Тип услуги' => :service_type,
        'Объем в МB' => :volume
        # 'Группа счетов' => nil, 'Номер базовой станции' => nil, 'Описание провайдера' => nil
    }
    array_utf8(headers).each_with_index do |h, key|
      name = cols[h.strip]
      ret[name] = key if name
    end
    ret
  end

  def array_utf8(a)
    a.map { |x| x.is_a?(String) ? x.encode : x }
  end
end
