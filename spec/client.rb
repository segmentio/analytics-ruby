require_relative '../lib/analytics'

module Analytics

  describe Analytics, "#test" do

    before(:all) { @client = Analytics::Client.new({ secret: "secret" }) }

    it "should error without an event" do
      expect { @client.track({ userId: "user" }) }.to raise_error
    end

    it "should error without a user or session" do
      expect { @client.track({ event: "My cool event" }) }.to raise_error
    end

  end
end