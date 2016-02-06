require 'kleisli/maybe'
require 'dry/types/decorator'

module Dry
  module Types
    class Optional
      include Decorator
      include Builder

      def call(input)
        if input.is_a? Kleisli::Maybe
          Maybe(type[input.value])
        else
          Maybe(type[input])
        end
      end
      alias_method :[], :call
    end
  end
end
