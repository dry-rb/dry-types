require 'dry/data/typed_hash'

module Dry
  module Data
    module Struct
      def self.included(klass)
        super
        klass.extend(Mixin)
        # TODO: we need inflector for underscore here
        Data.register(klass.name.downcase.to_sym, Type.new(klass.method(:new), klass))
      end

      module Mixin
        def attributes(schema)
          @constructor = TypedHash.new(schema)
          attr_reader(*schema.keys)
          self
        end

        def constructor
          @constructor
        end
      end

      def initialize(attributes)
        self.class.constructor[attributes].each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end
    end
  end
end
