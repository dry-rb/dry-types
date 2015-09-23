module Dry
  module Data
    class TypedHash
      attr_reader :schema

      def initialize(schema)
        @schema = schema.each_with_object({}) { |(name, type_id), result|
          result[name] =
            if type_id.respond_to?(:call)
              type_id
            else
              Dry::Data[type_id] || Dry::Data.new { |t| t[type_id] }
            end
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
