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
        try(input) do |result|
          raise ConstraintError, result
        end.input
      end
      alias_method :[], :call

      def try(input, &block)
        if type.is_a?(Constructor)
          result = type.try(input)

          if result.success?
            validation = rule.(result.input)

            if validation.success?
              result
            else
              block ? yield(validation) : validation
            end
          else
            block ? yield(result) : result
          end
        else
          validation = rule.(input)

          if validation.success?
            type.try(input, &block)
          else
            block ? yield(validation) : validation
          end
        end
      end

      def valid?(value)
        rule.(value).success?
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
