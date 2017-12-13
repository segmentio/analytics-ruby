require File.expand_path('../lib/segment/analytics/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'analytics-ruby'
  spec.version = Segment::Analytics::VERSION
  spec.files = Dir.glob('**/*')
  spec.require_paths = ['lib']
  spec.bindir = 'bin'
  spec.executables = ['analytics']
  spec.summary = 'Segment.io analytics library'
  spec.description = 'The Segment.io ruby analytics library'
  spec.authors = ['Segment.io']
  spec.email = 'friends@segment.io'
  spec.homepage = 'https://github.com/segmentio/analytics-ruby'
  spec.license = 'MIT'

  # Ruby 1.8 requires json
  spec.add_dependency 'json', ['~> 1.7'] if RUBY_VERSION < "1.9"
  spec.add_dependency 'commander', '~> 4.4'

  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'tzinfo', '1.2.1'
  spec.add_development_dependency 'activesupport', '~> 4.1.11'
  spec.add_development_dependency 'faraday', '~> 0.13'
  spec.add_development_dependency 'pmap', '~> 1.1'

  if RUBY_VERSION >= "2.1"
    spec.add_development_dependency 'rubocop', '~> 0.51.0'
  end

  spec.add_development_dependency 'codecov', '~> 0.1.4'
end
