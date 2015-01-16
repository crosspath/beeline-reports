class Call < ActiveRecord::Base
  belongs_to :subscriber

  scope :by_subscriber, lambda { |s| where(subscriber_id: s) }
  scope :before, lambda { |s| where('end_date <= ?', s) }
  scope :after, lambda { |s| where('start_date >= ?', s) }
  scope :between, lambda { |a, b| before(a).after(b) }
  scope :by_operator_name, lambda { |s| where('service like ?', "%#{s}%") } # operator_name: МТС, Билайн, Мегафон, гор

  class << self
    # Example: sum_cost_by_service
    def method_missing(meth, *args, &block)
      if meth.to_s =~ /^(sum|avg|min|max|count)_(#{column_names.join('|')})(?:_by_(#{column_names.join('|')}))?$/
        selector = select("#{$1}(#{$2}) as #{$2}").order($2)
        selector = selector.select($3).group($3) if $3.present?
        selector
      else
        super
      end
    end

    def phones
      pluck(:receiver).uniq
    end
  end

  class ActiveRecord_Relation
    def t
      header = select_values
      model_attrs = header.map { |x| x =~ /\S+\s+(\S+)\s*$/ ? $1 : x }
      values = to_a.map { |x| model_attrs.map { |h| x.read_attribute(h) } }
      max_length = []
      header.each_with_index { |x, i| max_length[i] = ([x.size]+values.map { |s| s[i].to_s.size }).max }

      line = '+'+max_length.map { |x| '-' * (x+2) }.join('+')+'+'
      cells = lambda do |row|
        '|'+row.map.with_index do |x, i|
          len = max_length[i]
          " #{x.to_s.send(x.is_a?(Fixnum) || x.is_a?(Float) ? :rjust : :ljust, len)} "
        end.join('|')+'|'
      end

      puts line
      puts cells.call(header)
      puts line
      values.each { |row| puts cells.call(row) }
      puts line
    end
  end
end
