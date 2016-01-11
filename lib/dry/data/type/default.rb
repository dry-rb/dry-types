module Dry
  module Data
    class Type
      class Default < Type
        attr_reader :type, :value

        def initialize(type, value)
          @type = type
          @value = value
        end

        def constructor
          type.constructor
        end

        def primitive
          type.primitive
        end

        def call(input)
          input.nil? ? value : super
        end
        alias_method :[], :call
      end
    end
  end
end
