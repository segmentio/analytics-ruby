require_relative '../lib/analytics'


describe Analytics::Client, '#track' do

  before(:all) { @client = Analytics::Client.new(secret: 'testsecret') }

  it 'should error without an event' do
    expect { @client.track(user_id: 'user') }.to raise_error(ArgumentError)
  end

  it 'should error without a user or session' do
    expect { @client.track(event: 'Event') }.to raise_error(ArgumentError)
  end

  it 'should not error with the required options' do
    @client.track(user_id: 'user',
                  event:   'Event')
  end

end
