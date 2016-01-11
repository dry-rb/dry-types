require 'dry/data/decorator'
require 'dry/data/constraints'

module Dry
  module Data
    class Constrained
      include Decorator
      include TypeBuilder

      attr_reader :rule

      def initialize(type, options)
        super
        @rule = options.fetch(:rule)
      end

      def call(input)
        result = try(input)

        if valid?(result)
          result
        else
          raise ConstraintError, "#{input.inspect} violates constraints"
        end
      end
      alias_method :[], :call

      def try(input)
        type[input]
      end

      def valid?(input)
        super && rule.(input).success?
      end

      def constrained(options)
        with(rule: rule & Data.Rule(primitive, options))
      end
    end
  end
end
