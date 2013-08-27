module Util
  def self.symbolize_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
  end

  def self.symbolize_keys!(hash)
    hash.replace symbolize_keys hash
  end

  def self.stringify_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
  end

  def self.isoify_dates(hash)
    hash.inject({}) { |memo, (k, v)|
      memo[k] = v.respond_to?(:iso8601) ? v.iso8601 : v
      memo
    }
  end

  def self.isoify_dates!(hash)
    hash.replace isoify_dates hash
  end
end