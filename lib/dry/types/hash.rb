require 'dry/types/hash/schema'

module Dry
  module Types
    class Hash < Definition
      # @param [{Symbol => Definition}] type_map
      # @param [Class] klass
      #   {Schema} or one of its subclasses ({Weak}, {Permissive}, {Strict},
      #   {StrictWithDefaults}, {Symbolized})
      # @return [Schema]
      def schema(type_map, klass = Schema)
        member_types = type_map.each_with_object({}) { |(name, type), result|
          result[name] =
            case type
            when String, Class then Types[type]
            else type
            end
        }

        klass.new(primitive, options.merge(member_types: member_types, meta: meta))
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Weak]
      def weak(type_map)
        schema(type_map, Weak)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Permissive]
      def permissive(type_map)
        schema(type_map, Permissive)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Strict]
      def strict(type_map)
        schema(type_map, Strict)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [StrictWithDefaults]
      def strict_with_defaults(type_map)
        schema(type_map, StrictWithDefaults)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Symbolized]
      def symbolized(type_map)
        schema(type_map, Symbolized)
      end

      private

      # @param [Hash] _result
      # @param [Symbol] _key
      # @param [Type] _type
      def resolve_missing_value(_result, _key, _type)
        # noop
      end
    end
  end
end
