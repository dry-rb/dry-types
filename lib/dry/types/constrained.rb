require 'dry/types/decorator'
require 'dry/types/constraints'

module Dry
  module Types
    class Constrained
      include Decorator
      include Builder

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
        with(rule: rule & Types.Rule(options))
      end

      private

      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
