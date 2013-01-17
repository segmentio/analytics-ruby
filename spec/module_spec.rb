require 'analytics'


describe Analytics, '#init' do

  it 'should successfully init' do
    Analytics.init secret: 'testsecret'
  end
end


describe Analytics, '#track' do

  it 'should error without an event' do
    expect { Analytics.track user_id: 'user' }.to raise_error(ArgumentError)
  end

  it 'should error without a user or session' do
    expect { Analytics.track event: 'Event' }.to raise_error(ArgumentError)
  end

  it 'should not error with the required options' do
    Analytics.track user_id: 'user',
                    event:   'Event'
  end

end
