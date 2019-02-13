require 'dry/types/hash/schema'
require 'dry/types/fn_container'

module Dry
  module Types
    class Hash < Definition
      # A bulder for legacy schemas
      # @api private
      class SchemaBuilder
        NIL_TO_UNDEFINED = -> v { v.nil? ? Undefined : v }
        OMITTABLE_KEYS = %i(schema weak symbolized).freeze
        STRICT = %i(strict strict_with_defaults).freeze

        # @param primitive [Type]
        # @option options [Hash{Symbol => Definition}] :member_types
        # @option options [Symbol] :hash_type
        def call(primitive, **options)
          hash_type = options.fetch(:hash_type)
          member_types = {}

          keys = options.fetch(:keys).map do |key|
            transform_key_type(hash_type, key)
          end

          instantiate(primitive, **options, keys: keys)
        end

        def instantiate(primitive, hash_type: :base, meta: EMPTY_HASH, **options)
          meta = meta.dup

          meta[:strict] = true if strict?(hash_type)
          meta[:key_transform_fn] = Schema::SYMBOLIZE_KEY if hash_type == :symbolized

          Schema.new(primitive, **options, meta: meta)
        end

        private

        def omittable?(constructor)
          OMITTABLE_KEYS.include?(constructor)
        end

        def strict?(constructor)
          STRICT.include?(constructor)
        end

        def transform_key_type(constructor, key)
          key = safe(constructor, key)
          key = default(constructor, key) if key.default?
          key = key.required(false) if omittable?(constructor)
          key
        end

        def safe(constructor, type)
          if constructor == :weak || constructor == :symbolized
            type.safe
          else
            type
          end
        end

        def default(constructor, key)
          case constructor
          when :strict_with_defaults
            key
          when :strict
            default = key.type
            key.new(default.type)
          else
            key.constructor(NIL_TO_UNDEFINED)
          end
        end
      end
    end
  end
end
