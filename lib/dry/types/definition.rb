require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Definition
      include Dry::Equalizer(:primitive, :options)
      include Options
      include Builder

      attr_reader :options

      attr_reader :primitive

      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      def initialize(primitive, options = {})
        super
        @primitive = primitive
        freeze
      end

      def name
        primitive.name
      end

      def default?
        false
      end

      def constrained?
        false
      end

      def call(input)
        input
      end
      alias_method :[], :call

      def try(input, &block)
        if valid?(input)
          success(input)
        else
          failure = failure(input, "#{input.inspect} must be an instance of #{primitive}")
          block ? yield(failure) : failure
        end
      end

      def success(input)
        Result::Success.new(input)
      end

      def failure(input, error)
        Result::Failure.new(input, error)
      end

      def result(klass, *args)
        klass.new(*args)
      end

      def primitive?(value)
        value.is_a?(primitive)
      end
      alias_method :valid?, :primitive?
    end
  end
end

require 'dry/types/array'
require 'dry/types/hash'
