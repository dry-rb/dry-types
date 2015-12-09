module Dry
  module Data
    class Type
      attr_reader :constructor
      attr_reader :primitive

      class Enum
        attr_reader :values
        attr_reader :type

        def initialize(values, type)
          @values = values
          @type = type
        end

        def call(input)
          type[input]
        end
        alias_method :[], :call
      end
    end
  end
end
