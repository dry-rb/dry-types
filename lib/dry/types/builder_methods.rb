module Dry
  module Types
    module BuilderMethods
      def Array(type)
        self::Array.of(type)
      end

      def Hash(schema, type_map)
        self::Hash.public_send(schema, type_map)
      end

      def Instance(klass)
        Definition.new(klass).constrained(type: klass)
      end

      def Value(value)
        Definition.new(value.class).constrained(eql: value)
      end

      def Constant(object)
        Definition.new(object.class).constrained(equal: object)
      end

      def Constructor(klass, cons = nil, &block)
        Definition.new(klass).constructor(cons || block)
      end
    end
  end
end
