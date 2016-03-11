module Dry
  module Types
    class Struct
      class << self
        attr_reader :constructor
      end

      def self.inherited(klass)
        super
        Types.register_class(klass) unless klass == Value
      end

      def self.attribute(name, type)
        attributes(name => type)
      end

      def self.attributes(new_schema)
        prev_schema = schema

        @schema = prev_schema.merge(new_schema)
        @constructor = Types['coercible.hash'].public_send(constructor_type, schema)

        attr_reader(*(new_schema.keys - prev_schema.keys))

        self
      end

      def self.constructor_type(type = :strict)
        @constructor_type ||= type
      end

      def self.schema
        super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
        super_schema.merge(@schema || {})
      end

      def self.new(attributes)
        if attributes.is_a?(self)
          attributes
        else
          super(constructor[attributes])
        end
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
