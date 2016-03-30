require 'dry/types/decorator'

module Dry
  module Types
    class Constructor < Definition
      include Dry::Equalizer(:type)

      attr_reader :fn

      attr_reader :type

      def self.new(input, options = {})
        type = input.is_a?(Definition) ? input : Definition.new(input)
        super(type, options)
      end

      def initialize(type, options = {})
        @type = type
        @fn = options.fetch(:fn)
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

      def constructor(new_fn, options = {})
        with(options.merge(fn: -> input { new_fn[fn[input]] }))
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
