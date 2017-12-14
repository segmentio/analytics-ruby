require 'rspec/core/rake_task'

default_tasks = []

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = "--tag ~e2e" if ENV["RUN_E2E_TESTS"] != "true"
end

default_tasks << :spec

# Rubocop doesn't support < 2.1
if RUBY_VERSION >= "2.1"
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['lib/**/*.rb','spec/**/*.rb',]
  end

  default_tasks << :rubocop
end

task :default => default_tasks
