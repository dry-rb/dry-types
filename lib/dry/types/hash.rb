require 'dry/types/hash/schema_builder'

module Dry
  module Types
    class Hash < Definition
      SCHEMA_BUILDER = SchemaBuilder.new.freeze

      # @param [{Symbol => Definition}] type_map
      # @param [Symbol] constructor
      # @return [Schema]
      def schema(type_map, constructor = nil)
        member_types = transform_types(type_map)

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

      # Build a map type
      #
      # @param [Type] key_type
      # @param [Type] value_type
      # @return [Map]
      def map(key_type, value_type)
        Map.new(
          primitive,
          key_type: resolve_type(key_type),
          value_type: resolve_type(value_type),
          meta: meta
        )
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
      # @param [{Symbol => Definition}] member_types
      # @return [Schema]
      def instantiate(member_types)
        SCHEMA_BUILDER.instantiate(primitive, **options, member_types: member_types)
      end

      # Injects a type transformation function for building schemas
      # @param [#call,nil] proc
      # @param [#call,nil] block
      # @return [Hash]
      def with_type_transform(proc = nil, &block)
        fn = proc || block

        if fn.nil?
          raise ArgumentError, "a block or callable argument is required"
        end

        handle = Dry::Types::FnContainer.register(fn)
        meta(type_transform_fn: handle)
      end

      private

      # @api private
      def transform_types(type_map)
        type_fn = meta.fetch(:type_transform_fn, Schema::NO_TRANSFORM)
        type_transform = Dry::Types::FnContainer[type_fn]

        type_map.each_with_object({}) { |(name, type), result|
          result[name] = type_transform.(
            resolve_type(type),
            name
          )
        }
      end

      # @api private
      def resolve_type(type)
        case type
        when String, Class then Types[type]
        else type
        end
      end
    end
  end
end
