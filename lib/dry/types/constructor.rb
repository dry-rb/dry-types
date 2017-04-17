require 'dry/types/decorator'

module Dry
  module Types
    class Constructor < Definition
      include Dry::Equalizer(:type)

      # @return [#call]
      attr_reader :fn

      # @return [Type]
      attr_reader :type

      # @param [Builder, Object] input
      # @param [Hash] options
      # @param [#call, nil] block
      def self.new(input, options = {}, &block)
        type = input.is_a?(Builder) ? input : Definition.new(input)
        super(type, options, &block)
      end

      # @param [Type] type
      # @param [Hash] options
      # @param [#call, nil] block
      def initialize(type, options = {}, &block)
        @type = type
        @fn = options.fetch(:fn, block)
        super
      end

      # @return [Class]
      def primitive
        type.primitive
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
      rescue TypeError => e
        failure(input, e.message)
      end

      # @param [#call, nil] new_fn
      # @param [Hash] options
      # @param [#call, nil] block
      # @return [Constructor]
      def constructor(new_fn = nil, **options, &block)
        left = new_fn || block
        right = fn

        with(options.merge(fn: -> input { left[right[input]] }))
      end

      # @param [Object] value
      # @return [Boolean]
      def valid?(value)
        super && type.valid?(value)
      end

      # @return [Class]
      def constrained_type
        Constrained::Coercible
      end

      private

      # @param [Symbol] meth
      # @param [Boolean] include_private
      # @return [Boolean]
      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      # Delegates missing methods to {#type}
      # @param [Symbol] meth
      # @param [Array] args
      # @param [#call, nil] block
      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if response.kind_of?(Builder)
            self.class.new(response, options)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
