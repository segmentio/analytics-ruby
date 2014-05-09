module Segment
  module Analytics
    module Utils
      extend self

      # public: Return a new hash with keys converted from strings to symbols
      #
      def symbolize_keys(hash)
        hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
      end

      # public: Convert hash keys from strings to symbols in place
      #
      def symbolize_keys!(hash)
        hash.replace symbolize_keys hash
      end

      # public: Return a new hash with keys as strings
      #
      def stringify_keys(hash)
        hash.inject({}) { |memo, (k,v)| memo[k.to_s] = v; memo }
      end

      # public: Returns a new hash with all the date values in the into iso8601
      #         strings
      #
      def isoify_dates(hash)
        hash.inject({}) { |memo, (k, v)|
          memo[k] = if v.is_a? Date
                      date_in_iso8601 v
                    elsif v.is_a? Time
                      time_in_iso8601 v
                    else
                      v
                    end
          memo
        }
      end

      # public: Converts all the date values in the into iso8601 strings in place
      #
      def isoify_dates!(hash)
        hash.replace isoify_dates hash
      end

      # public: Returns a uid string
      #
      def uid
        (0..16).to_a.map{|x| rand(16).to_s(16)}.join
      end

      def time_in_iso8601 time, fraction_digits = 0
        fraction = if fraction_digits > 0
                     (".%06i" % time.usec)[0, fraction_digits + 1]
                   end

        "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{fraction}#{formatted_offset(true, 'Z')}"
      end

      def date_in_iso8601 date
        date.strftime("%F")
      end
    end
  end
end
