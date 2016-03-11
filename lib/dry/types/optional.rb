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
    end
  end
end
