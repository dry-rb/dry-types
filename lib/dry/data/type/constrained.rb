require 'dry/data/constraints'

module Dry
  module Data
    class Type
      class Constrained < Type
        attr_reader :rule

        def initialize(constructor, primitive, rule)
          super(constructor, primitive)
          @rule = rule
        end

        def call(input)
          result = super(input)

          if valid?(result)
            result
          else
            raise ConstraintError, "+#{input}+ violates constraints"
          end
        end
        alias_method :[], :call

        def valid?(input)
          super && rule.(input).success?
        end
      end
    end
  end
end
