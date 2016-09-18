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

    module Builder
      def maybe
        Maybe.new(Types['strict.nil'] | self)
      end
    end

    class Hash
      module MaybeTypes
        def resolve_missing_value(result, key, type)
          if type.respond_to?(:maybe?) && type.maybe?
            result[key] = type[nil]
          else
            super
          end
        end
      end

      Schema.include MaybeTypes
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
