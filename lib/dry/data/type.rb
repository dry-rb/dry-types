require 'dry/data/type/hash'
require 'dry/data/type/array'
require 'dry/data/type/enum'
require 'dry/data/type/constrained'

require 'dry/data/sum_type'
require 'dry/data/optional'

module Dry
  module Data
    class Type
      attr_reader :constructor
      attr_reader :primitive

      def self.[](primitive)
        if primitive == ::Array
          Type::Array
        elsif primitive == ::Hash
          Type::Hash
        else
          Type
        end
      end

      def self.constructor(input)
        input
      end

      def initialize(constructor, primitive)
        @constructor = constructor
        @primitive = primitive
      end

      def enum(*values)
        Enum.new(values, constrained(inclusion: values))
      end

      def optional
        Optional.new(Data['nil'] | self)
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
        SumType.new(self, other)
      end
    end
  end
end
