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
        def call(primitive, options)
          hash_type = options.fetch(:hash_type)
          member_types = {}

          options.fetch(:member_types).each do |k, t|
            member_types[k] = build_type(hash_type, t)
          end

          instantiate(primitive, **options, member_types: member_types)
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

        def build_type(constructor, type)
          type = safe(constructor, type)
          type = default(constructor, type) if type.default?
          type = type.meta(omittable: true) if omittable?(constructor)
          type
        end

        def safe(constructor, type)
          if constructor == :weak || constructor == :symbolized
            type.safe
          else
            type
          end
        end

        def default(constructor, type)
          case constructor
          when :strict_with_defaults
            type
          when :strict
            type.type
          else
            type.constructor(NIL_TO_UNDEFINED)
          end
        end
      end
    end
  end
end
