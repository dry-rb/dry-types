require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :run_specs do
  require 'rspec/core'

  RSpec::Core::Runner.run(['spec/dry'])
  RSpec.clear_examples

  Dry::Types.load_extensions(:maybe)
  RSpec::Core::Runner.run(['spec'])
end

task default: :run_specs

require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new(:doc)
