module Dry
  module Data
    class Type
      class Composite
        attr_reader :left

        attr_reader :right

        def initialize(left, right)
          @left, @right = left, right
        end

        def call(input)
          if valid?(input)
            left.valid?(input) ? left.call(input) : right.call(input)
          else
            raise TypeError, input
          end
        end
        alias_method :[], :call

        def valid?(input)
          left.valid?(input) || right.valid?(input)
        end
      end
    end
  end
end
