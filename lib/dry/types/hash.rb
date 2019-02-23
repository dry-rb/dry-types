require 'dry/types/hash/schema_builder'
require 'dry/types/hash/key'
require 'dry/types/hash/constructor'

module Dry
  module Types
    class Hash < Definition
      SCHEMA_BUILDER = SchemaBuilder.new.freeze

      # @param [{Symbol => Definition}] type_map
      # @param [Symbol] constructor
      # @return [Schema]
      def schema(type_map, constructor = nil)
        keys = build_keys(type_map)

        if constructor.nil?
          Schema.new(primitive, keys: keys, **options, meta: meta)
        else
          SCHEMA_BUILDER.(
            primitive,
            **options,
            keys: keys,
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
      # @param [Array[Dry::Types::Hash::Key]] keys
      # @return [Schema]
      def instantiate(keys)
        SCHEMA_BUILDER.instantiate(primitive, **options, keys: keys)
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

      # @api private
      def constructor_type
        ::Dry::Types::Hash::Constructor
      end

      private

      # @api private
      def build_keys(type_map)
        type_fn = meta.fetch(:type_transform_fn, Schema::NO_TRANSFORM)
        type_transform = Dry::Types::FnContainer[type_fn]

        type_map.map do |name, type|
          key = Key.new(resolve_type(type), name)
          type_transform.(key)
        end
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
