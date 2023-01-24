require File.expand_path('../lib/segment/analytics/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'analytics-ruby'
  spec.version = Segment::Analytics::VERSION
  spec.files = Dir.glob("{lib,bin}/**/*")
  spec.require_paths = ['lib']
  spec.bindir = 'bin'
  spec.executables = ['analytics']
  spec.summary = 'Segment.io analytics library'
  spec.description = 'The Segment.io ruby analytics library'
  spec.authors = ['Segment.io']
  spec.email = 'friends@segment.io'
  spec.homepage = 'https://github.com/segmentio/analytics-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.0'

  # Used in the executable testing script
  spec.add_development_dependency 'commander', '~> 4.4'

  # Used in specs
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'tzinfo', '~> 1.2'
  spec.add_development_dependency 'activesupport', '~> 5.2.0'
  if RUBY_PLATFORM != 'java'
    spec.add_development_dependency 'oj', '~> 3.6.2'
  end
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'codecov', '~> 0.6'
end
