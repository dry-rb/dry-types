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

      def strict(type_map)
        schema(type_map, Strict)
      end

      def symbolized(type_map)
        schema(type_map, Symbolized)
      end
    end
  end
end
