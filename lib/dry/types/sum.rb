require 'dry/types/options'

module Dry
  module Types
    class Sum
      include Type
      include Dry::Equalizer(:left, :right, :options, :meta)
      include Builder
      include Options

      # @return [Type]
      attr_reader :left

      # @return [Type]
      attr_reader :right

      class Constrained < Sum
        # @return [Dry::Logic::Operations::Or]
        def rule
          left.rule | right.rule
        end

        # @return [true]
        def constrained?
          true
        end

        # @param [Object] input
        # @return [Object]
        # @raise [ConstraintError] if given +input+ not passing {#try}
        def call(input)
          try(input) do |result|
            raise ConstraintError.new(result, input)
          end.input
        end
        alias_method :[], :call
      end

      # @param [Type] left
      # @param [Type] right
      # @param [Hash] options
      def initialize(left, right, options = {})
        super
        @left, @right = left, right
        freeze
      end

      # @return [String]
      def name
        [left, right].map(&:name).join(' | ')
      end

      # @return [false]
      def default?
        false
      end

      # @return [false]
      def maybe?
        false
      end

      # @return [false]
      def constrained?
        false
      end

      # @return [Boolean]
      def optional?
        left == Types['strict.nil']
      end

      # @param [Object] input
      # @return [Object]
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

      def success(input)
        if left.valid?(input)
          left.success(input)
        elsif right.valid?(input)
          right.success(input)
        else
          raise ArgumentError, "Invalid success value '#{input}' for #{inspect}"
        end
      end

      def failure(input)
        if !left.valid?(input)
          left.failure(input, left.try(input).error)
        else
          right.failure(input, right.try(input).error)
        end
      end

      # @param [Object] value
      # @return [Boolean]
      def primitive?(value)
        left.primitive?(value) || right.primitive?(value)
      end

      # @param [Object] value
      # @return [Boolean]
      def valid?(value)
        left.valid?(value) || right.valid?(value)
      end
      alias_method :===, :valid?

      # @api public
      #
      # @see Definition#to_ast
      def to_ast(meta: true)
        [:sum, [left.to_ast(meta: meta), right.to_ast(meta: meta), meta ? self.meta : EMPTY_HASH]]
      end
    end
  end
end
