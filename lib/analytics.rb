
require 'rubygems'

require 'analytics/client'

module Analytics
  @@api_base = 'https://api.segment.io'

  def self.api_url(url='')
    @@api
  end
end
