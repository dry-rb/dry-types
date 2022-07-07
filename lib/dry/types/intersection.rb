# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/types/options"
require "dry/types/meta"

module Dry
  module Types
    # Sum type
    #
    # @api public
    class Intersection
      include Type
      include Builder
      include Options
      include Meta
      include Printable
      include Dry::Equalizer(:left, :right, :options, :meta, inspect: false, immutable: true)

      # @return [Type]
      attr_reader :left

      # @return [Type]
      attr_reader :right

      # @api private
      class Constrained < Intersection
        # @return [Dry::Logic::Operations::And]
        def rule
          left.rule & right.rule
        end

        # @return [true]
        def constrained?
          true
        end
      end

      # @param [Type] left
      # @param [Type] right
      # @param [Hash] options
      #
      # @api private
      def initialize(left, right, **options)
        super
        @left, @right = left, right
        freeze
      end

      # @return [String]
      #
      # @api public
      def name
        [left, right].map(&:name).join(" & ")
      end

      # @return [false]
      #
      # @api public
      def default?
        false
      end

      # @return [false]
      #
      # @api public
      def constrained?
        false
      end

      # @return [Boolean]
      #
      # @api public
      def optional?
        primitive?(nil)
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_unsafe(input)
        left.call_unsafe(input)
        right.call_unsafe(input)
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_safe(input, &block)
        left_failed = false

        left_result = left.call_safe(input) do
          left_failed = true
          yield
        end

        return left_result if left_failed

        right.call_safe(input, &block)
      end

      # @param [Object] input
      #
      # @api public
      def try(input)
        left_failed = false

        left_result = left.try(input) do |failure|

          left_failed = true
          if block_given?
            yield(failure)
          else
            failure
          end
        end

        return left_result if left_failed

        right.try(input) do |failure|
          if block_given?
            yield(failure)
          else
            failure
          end
        end
      end

      # @api private
      def success(input)
        if left.valid?(input) && right.valid?(input)
          left.success(input)
        else
          raise ArgumentError, "Invalid success value '#{input}' for #{inspect}"
        end
      end

      # @api private
      def failure(input, _error = nil)
        left.failure(input, left.try(input).error)
      end

      # @param [Object] value
      #
      # @return [Boolean]
      #
      # @api private
      def primitive?(value)
        left.primitive?(value) && right.primitive?(value)
      end

      # Manage metadata to the type. If the type is an optional, #meta delegates
      # to the right branch
      #
      # @see [Meta#meta]
      #
      # @api public
      def meta(data = Undefined)
        if Undefined.equal?(data)
          optional? ? right.meta : super
        elsif optional?
          self.class.new(left, right.meta(data), **options)
        else
          super
        end
      end

      # @see Nominal#to_ast
      #
      # @api public
      def to_ast(meta: true)
        [:intersection, [left.to_ast(meta: meta), right.to_ast(meta: meta), meta ? self.meta : EMPTY_HASH]]
      end

      # @param [Hash] options
      #
      # @return [Constrained,Sum]
      #
      # @see Builder#constrained
      #
      # @api public
      def constrained(options)
        if optional?
          right.constrained(options).optional
        else
          super
        end
      end

      # Wrap the type with a proc
      #
      # @return [Proc]
      #
      # @api public
      def to_proc
        proc { |value| self.(value) }
      end
    end
  end
end
