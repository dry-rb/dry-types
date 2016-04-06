module Dry
  module Types
    class Struct
      class << self
        attr_reader :constructor
      end

      def self.inherited(klass)
        super

        klass.instance_variable_set('@equalizer', Equalizer.new(*schema.keys))
        klass.instance_variable_set('@constructor_type', constructor_type)
        klass.send(:include, klass.equalizer)

        unless klass == Value
          klass.instance_variable_set('@constructor', Types['coercible.hash'])
          Types.register_class(klass)
        end

        klass.attributes({}) unless equal?(Struct)
      end

      def self.equalizer
        @equalizer
      end

      def self.attribute(name, type)
        attributes(name => type)
      end

      def self.attributes(new_schema)
        check_schema_duplication(new_schema)

        prev_schema = schema

        @schema = prev_schema.merge(new_schema)
        @constructor = Types['coercible.hash'].public_send(constructor_type, schema)

        attr_reader(*new_schema.keys)
        equalizer.instance_variable_get('@keys').concat(new_schema.keys)

        self
      end

      def self.check_schema_duplication(new_schema)
        shared_keys = new_schema.keys & schema.keys

        fail RepeatedAttributeError, shared_keys.first if shared_keys.any?
      end
      private_class_method :check_schema_duplication

      def self.constructor_type(type = nil)
        if type
          @constructor_type = type
        else
          @constructor_type || :strict
        end
      end

      def self.schema
        super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
        super_schema.merge(@schema || {})
      end

      def self.new(attributes = {})
        if attributes.instance_of?(self)
          attributes
        else
          super(constructor[attributes])
        end
      rescue SchemaError, SchemaKeyError => error
        raise StructError, "[#{self}.new] #{error}"
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
