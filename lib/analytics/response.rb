
module Analytics

  class Response

    attr_reader :status
    attr_reader :error

    def initialize(status = 200, error = nil)
      @status = status
      @error  = error
    end
  end
end