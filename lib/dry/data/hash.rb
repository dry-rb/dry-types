module Dry
  module Data
    class Hash
      attr_reader :container, :schema

      def initialize(schema, container = Dry::Data)
        @schema = schema.each_with_object({}) do |(name, type_id), result|
          result[name] = container[type_id]
        end
      end

      def call(input)
        Hash(input).each_with_object({}) do |(key, value), result|
          result[key] = schema[key][value]
        end
      end
      alias_method :[], :call
    end
  end
end
