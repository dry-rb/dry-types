require 'dry/types/hash/schema'

module Dry
  module Types
    class Hash < Definition
      def schema(type_map, klass = Schema)
        member_types = type_map.each_with_object({}) { |(name, type), result|
          result[name] =
            case type
            when String, Class then Types[type]
            else type
            end
        }

        klass.new(primitive, options.merge(member_types: member_types))
      end

      def weak(type_map)
        schema(type_map, Weak)
      end

      def permissive(type_map)
        schema(type_map, Permissive)
      end

      def strict(type_map)
        schema(type_map, Strict)
      end

      def strict_with_defaults(type_map)
        schema(type_map, StrictWithDefaults)
      end

      def symbolized(type_map)
        schema(type_map, Symbolized)
      end

      private

      def resolve_missing_value(_result, _key, _type)
        # noop
      end
    end
  end
end
