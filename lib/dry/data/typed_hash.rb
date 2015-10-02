module Dry
  module Data
    class TypedHash
      attr_reader :schema

      def initialize(schema)
        @schema = schema.each_with_object({}) { |(name, type_id), result|
          result[name] = Data[type_id]
        }
      end

      def call(input)
        Hash(input).each_with_object({}) { |(key, value), result|
          result[key] = schema[key][value]
        }
      end
      alias_method :[], :call
    end
  end
end
