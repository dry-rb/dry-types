module Dry
  module Data
    class Type
      class Enum
        attr_reader :values
        attr_reader :type

        def initialize(values, type)
          @values = values
          @type = type
        end

        def primitive
          type.primitive
        end

        def call(input)
          case input
          when Fixnum then type[values[input]]
          else type[input] end
        end
        alias_method :[], :call
      end
    end
  end
end
