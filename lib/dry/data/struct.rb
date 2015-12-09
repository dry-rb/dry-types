module Dry
  module Data
    class Struct
      def self.inherited(klass)
        super
        Data.register_class(klass, :constructor)
      end

      def self.attribute(*args)
        attributes(Hash[[args]])
      end

      def self.attributes(new_schema)
        prev_schema = schema || {}

        @schema = prev_schema.merge(new_schema)

        attr_reader(*(new_schema.keys - prev_schema.keys))

        self
      end

      def self.attribute_hash
        @attribute_hash ||= Data['coercible.hash'].strict(schema)
      end

      def self.constructor(attributes)
        self[attributes].new(attribute_hash[attributes])
      rescue SchemaError, SchemaKeyError => e
        raise StructError, "[#{self}.new] #{e.message}"
      end

      def self.schema
        super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
        super_schema.merge(@schema || {})
      end

      def self.[](_)
        self
      end

      def initialize(attributes)
        attributes.each { |key, value| instance_variable_set("@#{key}", value) }
      end
    end
  end
end
