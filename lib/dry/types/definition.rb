require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Definition
      include Type
      include Dry::Equalizer(:primitive, :options, :meta)
      include Options
      include Builder

      # @return [Hash]
      attr_reader :options

      # @return [Class]
      attr_reader :primitive

      # @param [Class] primitive
      # @return [Type]
      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      # @param [Type,Class] primitive
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

      # @return [false]
      def optional?
        false
      end

      # @param [BasicObject] input
      # @return [BasicObject]
      def call(input)
        input
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call,nil] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result,Logic::Result] when a block is not provided
      # @return [nil] otherwise
      def try(input, &block)
        if valid?(input)
          success(input)
        else
          failure = failure(input, "#{input.inspect} must be an instance of #{primitive}")
          block ? yield(failure) : failure
        end
      end

      # @param (see Dry::Types::Success#initialize)
      # @return [Result::Success]
      def success(input)
        Result::Success.new(input)
      end


      # @param (see Failure#initialize)
      # @return [Result::Failure]
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
      alias_method :===, :primitive?

      # Return AST representation of a type definition
      #
      # @api public
      #
      # @return [Array]
      def to_ast(meta: true)
        [:definition, [primitive, meta ? self.meta : EMPTY_HASH]]
      end
    end
  end
end

require 'dry/types/array'
require 'dry/types/hash'
