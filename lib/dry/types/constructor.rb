require 'dry/types/fn_container'

module Dry
  module Types
    class Constructor < Nominal
      include Dry::Equalizer(:type, :options, :meta, inspect: false)

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
        super(type, **options, &block)
      end

      # @param [Type] type
      # @param [Hash] options
      # @param [#call, nil] block
      def initialize(type, **options, &block)
        @type = type
        @fn = options.fetch(:fn, block)

        raise ArgumentError, 'Missing constructor block' if fn.nil?

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

      # @param [Object] input
      # @return [Object]
      def call(input)
        type[fn[input]]
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call,nil] block
      # @return [Logic::Result, Types::Result]
      # @return [Object] if block given and try fails
      def try(input, &block)
        type.try(fn[input], &block)
      rescue TypeError, ArgumentError => e
        failure(input, e.message)
      end

      # @param [#call, nil] new_fn
      # @param [Hash] options
      # @param [#call, nil] block
      # @return [Constructor]
      def constructor(new_fn = nil, **options, &block)
        left = new_fn || block
        right = fn

        with(**options, fn: -> input { left[right[input]] })
      end
      alias_method :append, :constructor
      alias_method :>>, :constructor

      # @param [Object] value
      # @return [Boolean]
      def valid?(value)
        constructed_value = fn[value]
      rescue NoMethodError, TypeError, ArgumentError
        false
      else
        type.valid?(constructed_value)
      end
      alias_method :===, :valid?

      # @return [Class]
      def constrained_type
        Constrained::Coercible
      end

      # @api public
      #
      # @see Nominal#to_ast
      def to_ast(meta: true)
        [:constructor, [type.to_ast(meta: meta),
                        register_fn(fn),
                        meta ? self.meta : EMPTY_HASH]]
      end

      # @api public
      #
      # @param [#call, nil] new_fn
      # @param [Hash] options
      # @param [#call, nil] block
      # @return [Constructor]
      def prepend(new_fn = nil, **options, &block)
        left = new_fn || block
        right = fn

        with(**options, fn: -> input { right[left[input]] })
      end
      alias_method :<<, :prepend

      private

      def register_fn(fn)
        Dry::Types::FnContainer.register(fn)
      end

      # @param [Symbol] meth
      # @param [Boolean] include_private
      # @return [Boolean]
      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      # Delegates missing methods to {#type}
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

      def composable?(value)
        value.kind_of?(Builder)
      end
    end
  end
end
