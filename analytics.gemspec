$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

Gem::Specification.new do |spec|
  spec.name    = "analytics-ruby"
  spec.version = "0.0.1"
  spec.files   = `git ls-files`.split("\n")
  spec.require_paths = ['lib']
  spec.summary = "Segment.io analytics library"
  spec.authors = ["friends@segment.io"]
end