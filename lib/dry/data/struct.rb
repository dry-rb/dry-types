module Dry
  module Data
    class Struct
      class << self
        attr_reader :constructor
      end

      def self.inherited(klass)
        super
        name = Inflecto.underscore(klass).gsub('/', '.')
        Data.register(name, Type.new(klass.method(:new), klass))
      end

      def self.attribute(*args)
        attributes(Hash[[args]])
      end

      def self.attributes(new_schema)
        prev_schema = schema || {}

        @schema = prev_schema.merge(new_schema)
        @constructor = Data['coercible.hash'].schema(schema)

        attr_reader(*(new_schema.keys - prev_schema.keys))

        self
      end

      def self.schema
        super_schema = superclass.respond_to?(:schema) ? superclass.schema : {}
        super_schema.merge(@schema || {})
      end

      def initialize(attributes)
        self.class.constructor[attributes].each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
