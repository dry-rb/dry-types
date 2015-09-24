require 'dry/data/type/composite'

module Dry
  module Data
    class Type
      IDENTITY_FN = ->(input) { input }.freeze

      attr_reader :constructor, :coercible_from

      def initialize(constructor, options)
        @constructor = constructor.respond_to?(:call) ? constructor : IDENTITY_FN
        @coercible_from = Array(options.fetch(:coerces_from, [Object]))
      end

      def call(input)
        if valid?(input)
          constructor[input]
        else
          raise TypeError, input
        end
      end
      alias_method :[], :call

      def valid?(input)
        coercible_from.any? { |type| input.kind_of?(type) }
      end

      def |(other)
        Composite.new(self, other)
      end
    end
  end
end
