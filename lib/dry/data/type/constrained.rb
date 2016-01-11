require 'dry/data/constraints'

module Dry
  module Data
    class Type
      class Constrained < Type
        include Decorator

        attr_reader :rule

        def initialize(type, options)
          super
          @rule = options.fetch(:rule)
        end

        def call(input)
          result = type[input]

          if valid?(result)
            result
          else
            raise ConstraintError, "#{input.inspect} violates constraints"
          end
        end
        alias_method :[], :call

        def valid?(input)
          super && rule.(input).success?
        end

        def constrained(options)
          with(rule: rule & Data.Rule(primitive, options))
        end
      end
    end
  end
end
