
require 'forwardable'
require 'analytics/version'
require 'analytics/client'

module Analytics
  extend SingleForwardable

  def_delegators :@client, :track, :identify

  # By default use a single client for the module
  def self.init(options = {})
    @client = Analytics::Client.new(options)
  end

end
