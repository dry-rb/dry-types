if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(File.join(__dir__, '..', '.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
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

Undefined = Dry::Core::Constants::Undefined

RSpec.configure do |config|
  config.before(:example, :maybe) do
    Dry::Types.load_extensions(:maybe)
  end

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
end

srand RSpec.configuration.seed
