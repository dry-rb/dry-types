require 'dry/types/hash/schema_builder'

module Dry
  module Types
    class Hash < Definition
      SCHEMA_BUILDER = SchemaBuilder.new

      # @param [{Symbol => Definition}] type_map
      # @param [Class] klass
      #   {Schema} or one of its subclasses ({Weak}, {Permissive}, {Strict},
      #   {StrictWithDefaults}, {Symbolized})
      # @return [Schema]
      def schema(type_map, constructor = :schema)
        member_types = type_map.each_with_object({}) { |(name, type), result|
          result[name] =
            case type
            when String, Class then Types[type]
            else type
            end
        }

        SCHEMA_BUILDER.(
          primitive,
          **options,
          member_types: member_types,
          meta: meta,
          hash_type: constructor
        )
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Weak]
      def weak(type_map)
        schema(type_map, :weak)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Permissive]
      def permissive(type_map)
        schema(type_map, :permissive)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Strict]
      def strict(type_map)
        schema(type_map, :strict)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [StrictWithDefaults]
      def strict_with_defaults(type_map)
        schema(type_map, :strict_with_defaults)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Symbolized]
      def symbolized(type_map)
        schema(type_map, :symbolized)
      end

      def instantiate(member_types)
        SCHEMA_BUILDER.instantiate(primitive, **options, member_types: member_types)
      end
    end
  end
end
