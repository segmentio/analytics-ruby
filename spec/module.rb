require_relative '../lib/analytics'

module Analytics

  describe Analytics, "#track" do

    before(:all) { Analytics.init(secret: "testsecret") }

    it "should error without an event" do
      expect { Analytics.track(user_id: "user") }.to raise_error(ArgumentError)
    end

    it "should error without a user or session" do
      expect { Analytics.track(event: "Event") }.to raise_error(ArgumentError)
    end

    it "should not error with the required options" do
      Analytics.track(user_id: "user",
                    event:   "Event")
    end

  end
end