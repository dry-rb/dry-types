require 'dry/types/options'

module Dry
  module Types
    module Decorator
      include Options

      # @return [Type]
      attr_reader :type

      # @param [Type] type
      def initialize(type, *)
        super
        @type = type
      end

      # @param [Object] input
      # @param [#call, nil] block
      # @return [Result,Logic::Result]
      # @return [Object] if block given and try fails
      def try(input, &block)
        type.try(input, &block)
      end

      # @param [Object] value
      # @return [Boolean]
      def valid?(value)
        type.valid?(value)
      end
      alias_method :===, :valid?

      # @return [Boolean]
      def default?
        type.default?
      end

      # @return [Boolean]
      def constrained?
        type.constrained?
      end

      # @param [Symbol] meth
      # @param [Boolean] include_private
      # @return [Boolean]
      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      private

      # @param [Object] response
      # @return [Boolean]
      def decorate?(response)
        response.kind_of?(type.class)
      end

      # Delegates missing methods to {#type}
      # @param [Symbol] meth
      # @param [Array] args
      # @param [#call, nil] block
      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if decorate?(response)
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
