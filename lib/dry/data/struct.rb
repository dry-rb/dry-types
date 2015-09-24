module Dry
  module Data
    module Struct
      def self.included(klass)
        super
        klass.extend(ClassMethods)
      end

      module ClassMethods
        attr_reader :constructor

        def attributes(schema)
          @constructor = Dry::Data::Hash.new(schema)
          attr_reader(*schema.keys)
          self
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
