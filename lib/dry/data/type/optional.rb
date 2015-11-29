module Dry
  module Data
    class Type
      class Optional < Type
        def |(other)
          Data.SumType(self.class.new(constructor, other.primitive), other)
        end

        def call(input)
          Maybe(input)
        end

        def valid?(input)
          input.nil? || super
        end
      end
    end
  end
end
