


module Analytics

  class Consumer

    def initialize(queue, options = {})
      @current_batch = []
      @queue = queue
      puts "Consumer intialized"
    end


    def flush

      while @current_batch.length < 40 && !@queue.empty? do
        @current_batch << @queue.pop()
      end

      @current_batch.each { |x| puts x }
    end

  end
end