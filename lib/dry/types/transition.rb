# frozen_string_literal: true

module Dry
  module Types
    # # Transition type
    #
    # It is a composition type, where the left type is an intermediary one and
    # the right type is a resulting.
    #
    # It differs from an {Implication} by an input for the right type: instead of
    # bypassing the original input, it will pass a coerced result of the left type.
    # The same effect is possible with a {Constructor} but {Transition} allows to
    # keep a transitive object as type instead of function.
    #
    # When the left type if failed it bypasses input value to the right type.
    #
    # @example Usage
    #   coercible_proc = Dry::Types::Nominal.new(Proc).constructor(&:to_proc)
    #   ceorcible_sym = Dry::Types['coercible.symbol']
    #
    #   # the left-hand type is resulting when is built with {Builder#<=}
    #   (coercible_proc <= coercible_sym)['example'] # => #<Proc:(&:example)>
    #
    #   # the right-hand type is resulting when is built with {Builder#>=}
    #   (coercible_sym >= coercible_proc)['example'] # => #<Proc:(&:example)>
    #
    # @api public
    class Transition
      include Composition

      def self.operator
        :>=
      end

      class Constrained < Transition
        def rule
          right.rule | left.rule
        end

        def pristine
          self.class.new(left, right.pristine, **@options)
        end
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_unsafe(input)
        left_result = left.try(input)
        if left_result.success?
          right.call_unsafe(left_result.input)
        else
          right.call_unsafe(input)
        end
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_safe(input, &block)
        left_result = left.try(input)
        if left_result.success?
          right.call_safe(left_result.input, &block)
        else
          right.call_safe(input, &block)
        end
      end

      # @param [Object] input
      #
      # @api public
      def try(input)
        left_result = left.try(input)

        if left_result.success?
          right.try(left_result.input)
        else
          right.try(input)
        end
      end

      # @param [Object] value
      #
      # @return [Boolean]
      #
      # @api private
      def primitive?(value)
        left_result = left.try(input)

        if left.primitive?(value)
          right.primitive?(left_result.input)
        else
          right.primitive?(value)
        end
      end

      # #meta always delegates to the right branch of Transition type
      #
      # @see [Meta#meta]
      #
      # @api public
      def meta(data = Undefined)
        if Undefined.equal?(data)
          right.meta
        else
          self.class.new(left, right.meta(data), **@options)
        end
      end

      # @param [Hash] options
      #
      # @return [Constrained,Sum]
      #
      # @see Builder#constrained
      #
      # @api public
      def constrained(options)
        self.class.new(left, right.constrained(options), **@options)
      end

      # Resets meta in the right type
      #
      # @return [Dry::Types::Type]
      #
      # @api public
      def pristine
        self.class.new(left, right.pristine, **@options)
      end
    end
  end
end