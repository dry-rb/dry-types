require 'dry/monads/maybe'
require 'dry/types/decorator'

module Dry
  module Types
    class Maybe
      include Type
      include Dry::Equalizer(:type, :options)
      include Decorator
      include Builder
      include Dry::Monads::Maybe::Mixin

      # @param [Dry::Monads::Maybe, Object] input
      # @return [Dry::Monads::Maybe]
      def call(input)
        input.is_a?(Dry::Monads::Maybe) ? input : Maybe(type[input])
      end
      alias_method :[], :call

      # @param [Object] input
      # @return [Result::Success]
      def try(input)
        Result::Success.new(Maybe(type[input]))
      end

      # @return [true]
      def maybe?
        true
      end

      # @param [Object] value
      # @see Dry::Types::Builder#default
      # @raise [ArgumentError] if nil provided as default value
      def default(value)
        if value.nil?
          raise ArgumentError, "nil cannot be used as a default of a maybe type"
        else
          super
        end
      end
    end

    module Builder
      # @return [Maybe]
      def maybe
        Maybe.new(Types['strict.nil'] | self)
      end
    end

    class Hash
      module MaybeTypes
        # @param [Hash] result
        # @param [Symbol] key
        # @param [Definition] type
        def resolve_missing_value(result, key, type)
          if type.respond_to?(:maybe?) && type.maybe?
            result[key] = type[nil]
          else
            super
          end
        end
      end

      class StrictWithDefaults < Strict
        include MaybeTypes
      end

      class Schema < Hash
        include MaybeTypes
      end
    end

    # Register non-coercible maybe types
    NON_NIL.each_key do |name|
      register("maybe.strict.#{name}", self["strict.#{name}"].maybe)
    end

    # Register coercible maybe types
    COERCIBLE.each_key do |name|
      register("maybe.coercible.#{name}", self["coercible.#{name}"].maybe)
    end
  end
end
