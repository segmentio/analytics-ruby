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

  spec.add_dependency 'faraday', ['>= 0.8']
  spec.add_dependency 'faraday_middleware', ['>= 0.8', '< 0.10']
  spec.add_dependency 'multi_json', ['~> 1.0']

  # Ruby 1.8 requires json for faraday_middleware
  spec.add_dependency 'json', ['~> 1.7'] if RUBY_VERSION < "1.9"

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
end
