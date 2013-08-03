module Util
  def self.symbolize_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
  end

  def self.symbolize_keys!(hash)
    hash.replace symbolize_keys(hash)
  end

  def self.stringify_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
  end
end