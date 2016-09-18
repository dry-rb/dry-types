require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :run_specs do
  require 'rspec/core'

  RSpec::Core::Runner.run(['spec/dry/types'])
  RSpec.clear_examples

  load 'spec/dry/types.rb'
  Dry::Types.load_extensions(:maybe)
  RSpec::Core::Runner.run(['spec'])
end

task default: :run_specs
