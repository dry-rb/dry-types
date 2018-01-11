require 'dry/types/hash/schema_builder'

module Dry
  module Types
    class Hash < Definition
      SCHEMA_BUILDER = SchemaBuilder.new.freeze

      # @param [{Symbol => Definition}] type_map
      # @param [Symbol] constructor
      # @return [Schema]
      def schema(type_map, constructor = nil)
        member_types = type_map.each_with_object({}) { |(name, type), result|
          result[name] =
            case type
            when String, Class then Types[type]
            else type
            end
        }

        if constructor.nil?
          Schema.new(primitive, member_types: member_types, **options, meta: meta)
        else
          SCHEMA_BUILDER.(
            primitive,
            **options,
            member_types: member_types,
            meta: meta,
            hash_type: constructor
          )
        end
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def weak(type_map)
        schema(type_map, :weak)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def permissive(type_map)
        schema(type_map, :permissive)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def strict(type_map)
        schema(type_map, :strict)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def strict_with_defaults(type_map)
        schema(type_map, :strict_with_defaults)
      end

      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def symbolized(type_map)
        schema(type_map, :symbolized)
      end

      # Build a schema from an AST
      # @api private
      # @param [{Symbol => Definition}] type_map
      # @return [Schema]
      def instantiate(member_types)
        SCHEMA_BUILDER.instantiate(primitive, **options, member_types: member_types)
      end
    end
  end
end
