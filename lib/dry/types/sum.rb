require 'dry/types/options'

module Dry
  module Types
    class Sum
      include Dry::Equalizer(:left, :right, :options)
      include Builder
      include Options

      attr_reader :left

      attr_reader :right

      class Constrained < Sum
        def rule
          left.rule | right.rule
        end

        def constrained?
          true
        end

        def call(input)
          try(input) do |result|
            raise ConstraintError.new(result, input)
          end.input
        end
        alias_method :[], :call
      end

      def initialize(left, right, options = {})
        super
        @left, @right = left, right
        freeze
      end

      def name
        [left, right].map(&:name).join(' | ')
      end

      def default?
        false
      end

      def maybe?
        false
      end

      def constrained?
        false
      end

      def call(input)
        try(input).input
      end
      alias_method :[], :call

      def try(input, &block)
        result = left.try(input) do
          right.try(input)
        end

        return result if result.success?

        if block
          yield(result)
        else
          result
        end
      end

      def primitive?(value)
        left.primitive?(value) || right.primitive?(value)
      end

      def valid?(value)
        left.valid?(value) || right.valid?(value)
      end
    end
  end
end
