module Dry
  module Data
    class Struct
      def self.inherited(klass)
        super
        # TODO: we need inflector for underscore here
        Data.register(klass.name.downcase, Type.new(klass.method(:new), klass))
      end

      def self.attributes(schema)
        @constructor = Data['strict.hash'].schema(schema)
        attr_reader(*schema.keys)
        self
      end

      def self.constructor
        @constructor
      end

      def initialize(attributes)
        self.class.constructor[attributes].each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
