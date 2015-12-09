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

          if rule.(result).success?
            result
          else
            raise ConstraintError, "#{input.inspect} violates constraints"
          end
        end
        alias_method :[], :call
      end

      def constrained(options)
        Constrained.new(constructor, primitive, Data.Rule(primitive, options))
      end
    end
  end
end
