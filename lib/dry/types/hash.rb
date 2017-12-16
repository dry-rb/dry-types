require 'dry/core/class_attributes'

module Dry
  module Types
    class Hash < Definition
      extend Dry::Core::ClassAttributes

      defines :hash_type

      defines :extra_keys, type: %i(ignore raise).method(:include?).to_proc

      extra_keys :ignore

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

        klass.new(
          primitive,
          **options,
          member_types: member_types,
          meta: meta,
          extra_keys: klass.extra_keys
        )
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

      def extra_keys(hash)
        case options[:extra_keys]
        when :ignore
          EMPTY_ARRAY
        when :raise
          hash.keys - member_types.keys
        end
      end

      def hash_type
        self.class.hash_type
      end
    end
  end
end

require 'dry/types/hash/schema'
