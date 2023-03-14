require 'rspec/core/rake_task'

default_tasks = []

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/segment/**/*_spec.rb'
end

default_tasks << :spec

# Isolated tests are run as separate rake tasks so that gem conflicts can be
# tests in different processes
Dir.glob('spec/isolated/**/*.rb').each do |isolated_test_path|
  RSpec::Core::RakeTask.new(isolated_test_path) do |spec|
    spec.pattern = isolated_test_path
  end

  default_tasks << isolated_test_path
end

# Older versions of Rubocop don't support a target Ruby version of 2.1
require 'rubocop/version'
if RuboCop::Version::STRING >= '1.30.0'
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['lib/**/*.rb','spec/**/*.rb',]
  end

  default_tasks << :rubocop
end

task :default => default_tasks
