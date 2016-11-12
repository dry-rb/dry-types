require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Definition
      include Dry::Equalizer(:primitive, :options)
      include Options
      include Builder

      # @return [Hash]
      attr_reader :options

      # @return [Class]
      attr_reader :primitive

      # @param [Class] primitive
      # @return [Definition]
      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      # @param [Class] primitive
      # @param [Hash] options
      def initialize(primitive, options = {})
        super
        @primitive = primitive
        freeze
      end

      # @return [String]
      def name
        primitive.name
      end

      # @return [false]
      def default?
        false
      end

      # @return [false]
      def constrained?
        false
      end

      # @param [Object] input
      # @return [Object]
      def call(input)
        input
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result]
      def try(input, &block)
        if valid?(input)
          success(input)
        else
          failure = failure(input, "#{input.inspect} must be an instance of #{primitive}")
          block ? yield(failure) : failure
        end
      end

      # @param (see Dry::Types::Success#initialize)
      # @return [Success]
      def success(input)
        Result::Success.new(input)
      end


      # @param (see Failure#initialize)
      # @return [Failure]
      def failure(input, error)
        Result::Failure.new(input, error)
      end

      # @param [Object] klass class of the result instance
      # @param [Array] args arguments for the +klass#initialize+ method
      # @return [Object] new instance of the given +klass+
      def result(klass, *args)
        klass.new(*args)
      end

      # Checks whether value is of a #primitive class
      # @param [Object] value
      # @return [Boolean]
      def primitive?(value)
        value.is_a?(primitive)
      end
      alias_method :valid?, :primitive?
    end
  end
end

require 'dry/types/array'
require 'dry/types/hash'
