require 'dry/data/sum_type'

module Dry
  module Data
    class Type
      attr_reader :constructor

      attr_reader :primitive

      class Array < Type
        def member(type)
          self.class.new(
            -> input { constructor[input].map(&type.constructor) },
            primitive
          )
        end
      end

      def self.[](primitive)
        if primitive == ::Array
          Type::Array
        else
          Type
        end
      end

      def initialize(constructor, primitive)
        @constructor = constructor
        @primitive = primitive
      end

      def name
        primitive.name
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call

      def valid?(input)
        input.instance_of?(primitive)
      end

      def |(other)
        Data.SumType(self, other)
      end
    end
  end
end
