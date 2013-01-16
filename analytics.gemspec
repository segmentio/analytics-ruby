$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

Gem::Specification.new do |spec|
  spec.name    = 'analytics-ruby'
  spec.version = '0.0.1'
  spec.files   = `git ls-files`.split('\n')
  spec.require_paths = ['lib']
  spec.summary = 'Segment.io analytics library'
  spec.authors = ['friends@segment.io']

  spec.add_dependency 'faraday', ['~> 0.8', '< 0.10']
  spec.add_dependency 'faraday_middleware', ['~> 0.9.0']
  spec.add_dependency 'multi_json', ['~> 1.0']
  spec.add_dependency 'typhoeus', ['~> 0.5.0']
end