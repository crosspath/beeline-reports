class Array
  def to_hash # [[key, value], [key, value]]
    h = {}
    each { |x| x.is_a?(Array) && x.size == 2 ? h[x.first] = x.last : raise('Invalid argument') }
    h
  end

  def pluck(key)
    map(&key)
  end
end
