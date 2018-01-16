
# Install any tools required to build this library, e.g. Ruby, Bundler etc.
bootstrap:
	brew install ruby
	gem install bundler

# Install any library dependencies.
dependencies:
	bundle install --verbose

# Run all tests and checks (including linters).
check:
	bundle exec rake

# Compile the code and produce any binaries where applicable.
build:
	gem build ./analytics-ruby.gemspec
