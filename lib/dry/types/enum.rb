require 'dry/types/decorator'

module Dry
  module Types
    class Enum < BasicObject
      include Decorator

      attr_reader :values, :mapping

      def initialize(type, options)
        super
        @values = options.fetch(:values).freeze
        @values.each(&:freeze)
        @mapping = values.each_with_object({}) { |v, h| h[values.index(v)] = v }.freeze
      end

      def call(input)
        value =
          if values.include?(input)
            input
          elsif mapping.key?(input)
            mapping[input]
          end

        type[value || input]
      end
      alias_method :[], :call
    end
  end
end
