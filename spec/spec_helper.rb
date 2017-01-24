if ENV['CI'] == 'true' && RUBY_ENGINE == 'ruby'
  require "simplecov"
  SimpleCov.start do
    add_filter '/spec/'
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pathname'
require 'dry-types'

begin
  require 'byebug'
  require 'mutant'

  module Mutant
    class Selector
      class Expression < self
        def call(_subject)
          integration.all_tests
        end
      end # Expression
    end # Selector
  end # Mutant
rescue LoadError; end

Dir[Pathname(__dir__).join('shared/*.rb')].each(&method(:require))
require_relative '../lib/spec/dry/types'

RSpec.configure do |config|
  config.before do
    @types = Dry::Types.container._container.keys

    module Test
      def self.remove_constants
        constants.each { |const| remove_const(const) }
        self
      end
    end
  end

  config.after do
    container = Dry::Types.container._container
    (container.keys - @types).each { |key| container.delete(key) }
    Dry::Types.instance_variable_set('@type_map', Concurrent::Map.new)

    Object.send(:remove_const, Test.remove_constants.name)
  end

  config.order = 'random'

  config.before(:example, :maybe) do
    Dry::Types.load_extensions(:maybe)
  end
end

srand RSpec.configuration.seed
