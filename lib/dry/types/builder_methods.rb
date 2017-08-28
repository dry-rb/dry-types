module Dry
  module Types
    module BuilderMethods
      # Build an array type.
      # It is a shortcut for Array.of
      #
      # @example
      #   Types::Strings = Types.Array(Types::String)
      #
      # @param [Dry::Types::Type] type
      #
      # @return [Dry::Types::Array]
      def Array(type)
        self::Array.of(type)
      end

      # Build a hash schema
      #
      # @param [Symbol] schema Schema type
      # @param [Hash{Symbol => Dry::Types::Type}] type_map
      #
      # @return [Dry::Types::Array]
      # @api public
      def Hash(schema, type_map)
        self::Hash.public_send(schema, type_map)
      end

      # Build a type which values are instances of a given class
      # Values are checked using `is_a?` call
      #
      # @param [Class,Module] klass Class or module
      #
      # @return [Dry::Types::Type]
      # @api public
      def Instance(klass)
        Definition.new(klass).constrained(type: klass)
      end

      # Build a type with a single value
      # The equality check done with `eql?`
      #
      # @param [Object] value
      #
      # @return [Dry::Types::Type]
      # @api public
      def Value(value)
        Definition.new(value.class).constrained(eql: value)
      end

      # Build a type with a single value
      # The equality check done with `equal?`
      #
      # @param [Object] object
      #
      # @return [Dry::Types::Type]
      # @api public
      def Constant(object)
        Definition.new(object.class).constrained(equal: object)
      end

      # Build a constructor type
      #
      # @param [Class] klass
      # @param [#call,nil] cons Value constructor
      # @param [#call,nil] block Value constructor
      #
      # @return [Dry::Types::Type]
      # @api public
      def Constructor(klass, cons = nil, &block)
        Definition.new(klass).constructor(cons || block)
      end
    end
  end
end
