# frozen_string_literal: true

require 'dry/types/fn_container'
require 'dry/types/constructor/function'

module Dry
  module Types
    class Constructor < Nominal
      include Dry::Equalizer(:type, :options, inspect: false)

      private :meta

      # @return [#call]
      attr_reader :fn

      # @return [Type]
      attr_reader :type

      undef :constrained?

      # @param [Builder, Object] input
      # @param [Hash] options
      # @param [#call, nil] block
      def self.new(input, **options, &block)
        type = input.is_a?(Builder) ? input : Nominal.new(input)
        super(type, **options, fn: Function[options.fetch(:fn, block)])
      end

      # @param [Type] type
      # @param [Function] fn
      # @param [Hash] options
      def initialize(type, fn: nil, **options)
        @type = type
        @fn = fn

        super(type, **options, fn: fn)
      end

      # @return [Class]
      def primitive
        type.primitive
      end

      # @return [String]
      def name
        type.name
      end

      # @return [Boolean]
      def default?
        type.default?
      end

      # @api private
      # @return [Object]
      def call_safe(input)
        coerced = fn.(input) { return yield }
        type.call_safe(coerced) { |output = coerced| yield(output) }
      end

      # @api private
      # @return [Object]
      def call_unsafe(input)
        type.call_unsafe(fn.(input))
      end

      # @param [Object] input
      # @param [#call,nil] block
      # @return [Logic::Result, Types::Result]
      # @return [Object] if block given and try fails
      def try(input, &block)
        value = fn.(input)
      rescue CoercionError => error
        failure = failure(input, error)
        block_given? ? yield(failure) : failure
      else
        type.try(value, &block)
      end

      # Build a new constructor by appending a block to the coercion function
      #
      # @param [#call, nil] new_fn
      # @param [Hash] options
      # @param [#call, nil] block
      # @return [Constructor]
      def constructor(new_fn = nil, **options, &block)
        with({**options, fn: fn >> (new_fn || block)})
      end
      alias_method :append, :constructor
      alias_method :>>, :constructor

      # @return [Class]
      def constrained_type
        Constrained::Coercible
      end

      # @see Nominal#to_ast
      def to_ast(meta: true)
        [:constructor, [type.to_ast(meta: meta), fn.to_ast]]
      end

      # Build a new constructor by prepending a block to the coercion function
      #
      # @param [#call, nil] new_fn
      # @param [Hash] options
      # @param [#call, nil] block
      # @return [Constructor]
      def prepend(new_fn = nil, **options, &block)
        with({**options, fn: fn << (new_fn || block)})
      end
      alias_method :<<, :prepend

      # Build a lax type
      #
      # @return [Lax]
      def lax
        Lax.new(Constructor.new(type.lax, options))
      end

      # Wrap the type with a proc
      #
      # @return [Proc]
      def to_proc
        proc { |value| self.(value) }
      end

      private

      # @api private
      #
      # @param [Symbol] meth
      # @param [Boolean] include_private
      # @return [Boolean]
      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      # Delegates missing methods to {#type}
      #
      # @api private
      #
      # @param [Symbol] method
      # @param [Array] args
      # @param [#call, nil] block
      def method_missing(method, *args, &block)
        if type.respond_to?(method)
          response = type.__send__(method, *args, &block)

          if composable?(response)
            response.constructor_type.new(response, options)
          else
            response
          end
        else
          super
        end
      end

      # @api private
      def composable?(value)
        value.is_a?(Builder)
      end
    end
  end
end
