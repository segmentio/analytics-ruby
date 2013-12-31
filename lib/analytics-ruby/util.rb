module Util

  # public: Return a new hash with keys converted from strings to symbols
  #
  def self.symbolize_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
  end

  # public: Convert hash keys from strings to symbols in place
  #
  def self.symbolize_keys!(hash)
    hash.replace symbolize_keys hash
  end

  # public: Return a new hash with keys as strings
  #
  def self.stringify_keys(hash)
    hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
  end

  # public: Returns a new hash with all the date values in the into iso8601
  #         strings
  #
  def self.isoify_dates(hash)
    hash.inject({}) { |memo, (k, v)|
      memo[k] = v.respond_to?(:iso8601) ? v.iso8601 : v
      memo
    }
  end

  # public: Converts all the date values in the into iso8601 strings in place
  #
  def self.isoify_dates!(hash)
    hash.replace isoify_dates hash
  end

  # public: Returns a uid string
  #
  def self.uid
    (0..16).to_a.map{|x| rand(16).to_s(16)}.join
  end
end