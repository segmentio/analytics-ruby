
module AnalyticsRuby

  class Response

    attr_reader :status
    attr_reader :error

    # public: Simple class to wrap responses from the API
    #
    #
    def initialize(status = 200, error = nil)
      @status = status
      @error  = error
    end
  end
end