module Dry
  module Data
    class Type
      class Array < Type
        def self.constructor(array_constructor, value_constructor, input)
          array_constructor[input].map(&value_constructor)
        end

        def member(type)
          self.class.new(
            self.class.method(:constructor).to_proc.curry.(constructor, type.constructor),
            primitive
          )
        end
      end
    end
  end
end
