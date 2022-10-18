# frozen_string_literal: true

require "dry/core/equalizer"
require "dry/types/options"
require "dry/types/meta"

module Dry
  module Types
    # Intersection type
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
        false
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_unsafe(input)
        merge_results(left.call_unsafe(input), right.call_unsafe(input))
      end

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api private
      def call_safe(input, &block)
        try_sides(input, &block).input
      end

      # @param [Object] input
      #
      # @api public
      def try(input)
        try_sides(input) do |failure|
          if block_given?
            yield(failure)
          else
            failure
          end
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
        left.primitive?(value) && right.primitive?(value)
      end

      # @see Nominal#to_ast
      #
      # @api public
      def to_ast(meta: true)
        [:intersection,
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

      private

      # @api private
      def try_sides(input, &block)
        results = []

        [left, right].each do |side|
          result = try_side(side, input, &block)
          return result if result.failure?

          results << result
        end

        Result::Success.new(merge_results(*results.map(&:input)))
      end

      # @api private
      def try_side(side, input)
        failure = nil

        result = side.try(input) do |f|
          failure = f
          yield(f)
        end

        if result.is_a?(Result)
          result
        elsif failure
          Result::Failure.new(result, failure)
        else
          Result::Success.new(result)
        end
      end

      # @api private
      def merge_results(left_result, right_result)
        case left_result
        when ::Array
          left_result
            .zip(right_result)
            .map { |lhs, rhs| merge_results(lhs, rhs) }
        when ::Hash
          left_result.merge(right_result)
        else
          left_result
        end
      end
    end
  end
end
