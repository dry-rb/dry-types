require 'kleisli/maybe'
require 'dry/types/decorator'

module Dry
  module Types
    class Optional
      include Decorator
      include Builder

      def call(input)
        input.is_a?(Kleisli::Maybe) ? input : Maybe(type[input])
      end
      alias_method :[], :call

      def default(value)
        if value.nil?
          raise ArgumentError, "nil cannot be used as a default of an optional type"
        else
          super
        end
      end
    end
  end
end
