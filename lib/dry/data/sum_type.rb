require 'kleisli'

module Dry
  module Data
    def self.SumType(left, right)
      klass =
        if left.primitive == NilClass
          SumType::Optional
        else
          SumType
        end
      klass.new(left, right)
    end

    class SumType
      attr_reader :left

      attr_reader :right

      class Optional < SumType
        def call(input)
          Maybe(super(input))
        end
        alias_method :[], :call
      end

      def initialize(left, right)
        @left, @right = left, right
      end

      def name
        [left, right].map(&:name).join(' | ')
      end

      def call(input)
        if valid?(input)
          input
        else
          raise TypeError, "#{input.inspect} has invalid type"
        end
      end
      alias_method :[], :call

      def valid?(input)
        left.valid?(input) || right.valid?(input)
      end
    end
  end
end
