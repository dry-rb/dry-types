require 'dry/types/decorator'

module Dry
  module Types
    class Constructor < Definition
      include Dry::Equalizer(:type)

      undef_method :primitive

      attr_reader :fn

      attr_reader :type

      def self.new(input, options = {})
        type = input.is_a?(Definition) ? input : Definition.new(input)
        super(type, options)
      end

      def initialize(type, options = {})
        super
        @type = type
        @fn = options.fetch(:fn)
      end

      def primitive
        type.primitive
      end

      def call(input)
        fn[input]
      end
      alias_method :[], :call

      def constructor(new_fn, options = {})
        with(options.merge(fn: -> input { new_fn[fn[input]] }))
      end

      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      private

      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if response.is_a?(Constructor)
            constructor(response.fn, options.merge(response.options))
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
