
require 'forwardable'

require 'analytics/client'

module Analytics
  extend SingleForwardable

  def_delegators :@client, :track, :identify

  def self.init(options = {})
    @client = Analytics::Client.new(options)
  end

end
