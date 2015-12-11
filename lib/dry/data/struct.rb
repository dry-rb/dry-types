module Dry
  module Data
    class Struct
      class << self
        attr_reader :constructor
      end

      def self.inherited(klass)
        super
        Data.register_class(klass) unless klass == Value
      end

      def self.attribute(*args)
        attributes(Hash[[args]])
      end

      def self.attributes(new_schema)
        prev_schema = schema || {}

        @schema = prev_schema.merge(new_schema)
        @constructor = Data['coercible.hash'].strict(schema)

        attr_reader(*(new_schema.keys - prev_schema.keys))

        self
      end

      def self.schema
        super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
        super_schema.merge(@schema || {})
      end

      def self.new(attributes)
        super(constructor[attributes])
      rescue SchemaError, SchemaKeyError => e
        raise StructError, "[#{self}.new] #{e.message}"
      end

      def initialize(attributes)
        attributes.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def [](name)
        public_send(name)
      end

      def to_hash
        self.class.schema.keys.each_with_object({}) { |key, result|
          value = self[key]
          result[key] = value.respond_to?(:to_hash) ? value.to_hash : value
        }
      end
      alias_method :to_h, :to_hash
    end
  end
end
