require 'dry/data/type/optional'
require 'dry/data/type/hash'
require 'dry/data/type/array'
require 'dry/data/type/enum'

require 'dry/data/sum_type'

module Dry
  module Data
    class Type
      attr_reader :constructor
      attr_reader :primitive

      class Constrained < Type
        attr_reader :rule

        def initialize(constructor, primitive, rule)
          super(constructor, primitive)
          @rule = rule
        end

        def call(input)
          result = super(input)

          if rule.(result).success?
            result
          else
            raise ConstraintError, "#{input.inspect} violates constraints"
          end
        end
        alias_method :[], :call
      end

      def self.[](primitive)
        if primitive == ::Array
          Type::Array
        elsif primitive == ::Hash
          Type::Hash
        else
          Type
        end
      end

      def self.strict_constructor(primitive, input)
        if input.is_a?(primitive)
          input
        else
          raise TypeError, "#{input.inspect} has invalid type"
        end
      end

      def self.passthrough_constructor(input)
        input
      end

      def initialize(constructor, primitive)
        @constructor = constructor
        @primitive = primitive
      end

      def enum(*values)
        Enum.new(values, constrained(inclusion: values))
      end

      def name
        primitive.name
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call

      def valid?(input)
        input.is_a?(primitive)
      end

      def |(other)
        Data.SumType(self, other)
      end
    end
  end
end
