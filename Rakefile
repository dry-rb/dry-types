# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :run_specs do
  require 'rspec/core'

  types_result = RSpec::Core::Runner.run(['spec/dry'])
  RSpec.clear_examples

  Dry::Types.load_extensions(:maybe)
  ext_result = RSpec::Core::Runner.run(['spec'])

  exit [types_result, ext_result].max
end

task default: :run_specs

require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new(:doc)
