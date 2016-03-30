require 'dry/types/decorator'

module Dry
  module Types
    class Constructor < Definition
      include Dry::Equalizer(:type)

      attr_reader :fn

      attr_reader :type

      def self.new(input, options = {}, &block)
        type = input.is_a?(Builder) ? input : Definition.new(input)
        super(type, options, &block)
      end

      def initialize(type, options = {}, &block)
        @type = type
        @fn = options.fetch(:fn, block)
        super
      end

      def primitive
        type.primitive
      end

      def call(input)
        type[fn[input]]
      end
      alias_method :[], :call

      def try(input, &block)
        type.try(fn[input], &block)
      rescue TypeError => e
        failure(input, e.message)
      end

      def constructor(new_fn = nil, **options, &block)
        left = new_fn || block
        right = fn

        with(options.merge(fn: -> input { left[right[input]] }))
      end

      def valid?(value)
        super && type.valid?(value)
      end

      def constrained_type
        Constrained::Coercible
      end

      private

      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

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
