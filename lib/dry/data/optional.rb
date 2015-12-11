module Dry
  module Data
    class Optional
      attr_reader :type

      def initialize(type)
        @type = type
      end

      def valid?(input)
        type.valid?(input)
      end

      def call(input)
        Maybe(type[input])
      end
      alias_method :[], :call
    end
  end
end
