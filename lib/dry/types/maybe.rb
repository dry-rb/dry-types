require 'dry/monads/maybe'
require 'dry/types/decorator'

module Dry
  module Types
    class Maybe
      include Dry::Equalizer(:type, :options)
      include Decorator
      include Builder
      include Dry::Monads::Maybe::Mixin

      def call(input)
        input.is_a?(Dry::Monads::Maybe) ? input : Maybe(type[input])
      end
      alias_method :[], :call

      def try(input)
        Result::Success.new(Maybe(type[input]))
      end

      def maybe?
        true
      end

      def default(value)
        if value.nil?
          raise ArgumentError, "nil cannot be used as a default of a maybe type"
        else
          super
        end
      end
    end
  end
end
