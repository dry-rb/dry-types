module Dry
  module Data
    class Type
      class Array < Type
        def member(type)
          self.class.new(
            -> input { constructor[input].map(&type.constructor) },
            primitive
          )
        end
      end
    end
  end
end
