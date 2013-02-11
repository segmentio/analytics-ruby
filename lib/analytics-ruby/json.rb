require 'multi_json'

module AnalyticsRuby

  # JSON Wrapper module adapted from
  # https://github.com/stripe/stripe-ruby/blob/master/lib/stripe/json.rb
  #
  # .dump was added in MultiJson 1.3
  module JSON
    if MultiJson.respond_to?(:dump)
      def self.dump(*args)
        MultiJson.dump(*args)
      end

      def self.load(*args)
        MultiJson.load(*args)
      end
    else
      def self.dump(*args)
        MultiJson.encode(*args)
      end

      def self.load(*args)
        MultiJson.decode(*args)
      end
    end
  end
end