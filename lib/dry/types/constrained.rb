require 'dry/types/decorator'
require 'dry/types/constraints'
require 'dry/types/constrained/coercible'

module Dry
  module Types
    class Constrained
      include Dry::Equalizer(:type, :options, :rule)
      include Decorator
      include Builder

      attr_reader :rule

      def initialize(type, options)
        super
        @rule = options.fetch(:rule)
      end

      def call(input)
        try(input) do |result|
          raise ConstraintError.new(result, input)
        end.input
      end
      alias_method :[], :call

      def try(input, &block)
        result = rule.(input)

        if result.success?
          type.try(input, &block)
        else
          failure = failure(input, result)
          block ? yield(failure) : failure
        end
      end

      def valid?(value)
        rule.(value).success?
      end

      def constrained(options)
        with(rule: rule & Types.Rule(options))
      end

      def constrained?
        true
      end

      private

      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
