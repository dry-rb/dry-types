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

      class Hash < Type
        def schema(type_map)
          constructors = type_map.each_with_object({}) { |(name, type_id), result|
            result[name] = Data[type_id]
          }

          hash_constructor = -> input {
            attributes = constructor[input]

            constructors.each_with_object({}) { |(key, val_constructor), result|
              result[key] = val_constructor[attributes.fetch(key)]
            }
          }

          self.class.new(hash_constructor, primitive)
        end
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
