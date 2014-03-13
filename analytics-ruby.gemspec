$:.push File.expand_path('../lib', __FILE__)

require 'analytics-ruby/version'


Gem::Specification.new do |spec|
  spec.name    = 'analytics-ruby'
  spec.version = AnalyticsRuby::VERSION
  spec.files   = Dir.glob('**/*')
  spec.require_paths = ['lib']
  spec.summary = 'Segment.io analytics library'
  spec.description = 'The Segment.io ruby analytics library'
  spec.authors = ['Segment.io']
  spec.email = 'friends@segment.io'
  spec.homepage = 'https://github.com/segmentio/analytics-ruby'
  spec.license = 'MIT'

  # Ruby 1.8 requires json
  spec.add_dependency 'json', ['~> 1.7'] if RUBY_VERSION < "1.9"

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
end
