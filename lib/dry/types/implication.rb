# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/types/options"
require "dry/types/meta"

module Dry
  module Types
    # Implication type
    #
    # @api public
    class Implication
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
      class Constrained < Implication
        # @return [Dry::Logic::Operations::Implication]
        def rule
          left.rule > right.rule
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
        [left, right].map(&:name).join(" > ")
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
        false
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_unsafe(input)
        if left.try(input).success?
          right.call_unsafe(input)
        else
          input
        end
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_safe(input, &block)
        if left.try(input).success?
          right.call_safe(input, &block)
        else
          input
        end
      end

      # @param [Object] input
      #
      # @api public
      def try(input)
        if left.try(input).success?
          right.try(input)
        else
          Result::Success.new(input)
        end
      end

      # @api private
      def success(input)
        result = try(input)
        if result.success?
          result
        else
          raise ArgumentError, "Invalid success value '#{input}' for #{inspect}"
        end
      end

      # @api private
      def failure(input, _error = nil)
        Result::Failure.new(input, try(input).error)
      end

      # @param [Object] value
      #
      # @return [Boolean]
      #
      # @api private
      def primitive?(value)
        if left.primitive?(value)
          right.primitive?(value)
        else
          true
        end
      end

      # @see Nominal#to_ast
      #
      # @api public
      def to_ast(meta: true)
        [:implication,
         [left.to_ast(meta: meta), right.to_ast(meta: meta), meta ? self.meta : EMPTY_HASH]]
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
