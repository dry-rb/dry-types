require 'dry/types/hash/schema'

module Dry
  module Types
    class Hash < Definition
      SCHEMAS = {
        schema: LegacySchema,
        weak: Weak,
        permissive: Permissive,
        strict: Strict,
        strict_with_defaults: StrictWithDefaults,
        symbolized: Symbolized
      }.freeze
      private_constant(:SCHEMAS)

      # @param [{Symbol => Definition}] type_map
      # @param [Class] klass
      #   {Schema} or one of its subclasses ({Weak}, {Permissive}, {Strict},
      #   {StrictWithDefaults}, {Symbolized})
      # @return [Schema]
      def schema(type_map, klass = LegacySchema)
        member_types = type_map.each_with_object({}) { |(name, type), result|
          result[name] =
            case type
            when String, Class then Types[type]
            else type
            end
        }

        klass.build(primitive, **options, member_types: member_types, meta: meta)
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

      def schema_transformed(constructor, member_types)
        klass = SCHEMAS.fetch(constructor)
        klass.new(primitive, **options, member_types: member_types, meta: meta)
      end
    end
  end
end
