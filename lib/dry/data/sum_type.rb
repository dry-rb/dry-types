require 'kleisli'

module Dry
  module Data
    class SumType
      attr_reader :left

      attr_reader :right

      def initialize(left, right)
        @left, @right = left, right
      end

      def name
        [left, right].map(&:name).join(' | ')
      end

      def call(input)
        value = left[input]

        if left.valid?(value)
          value
        else
          right[value]
        end
      end
      alias_method :[], :call

      def valid?(input)
        left.valid?(input) || right.valid?(input)
      end
    end
  end
end
