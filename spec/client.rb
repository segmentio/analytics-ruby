require_relative '../lib/analytics'

module Analytics

  describe Analytics::Client, "#track" do

    before(:all) { @client = Analytics::Client.new(secret: "secret") }

    it "should error without an event" do
      expect { @client.track(user_id: "user") }.to raise_error(ArgumentError)
    end

    it "should error without a user or session" do
      expect { @client.track(event: "Event") }.to raise_error(ArgumentError)
    end

    it "should not error with the required options" do
      @client.track(user_id: "user",
                    event:   "Event")
      sleep 2
    end

  end
end