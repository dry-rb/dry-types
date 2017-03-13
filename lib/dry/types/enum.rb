require 'dry/types/decorator'

module Dry
  module Types
    class Enum
      include Type
      include Dry::Equalizer(:type, :options, :values)
      include Decorator

      # @return [Array]
      attr_reader :values

      # @return [Hash]
      attr_reader :mapping

      # @param [Definition] type
      # @param [Hash] options
      # @option options [Array] :values
      def initialize(type, options)
        super
        @values = options.fetch(:values).freeze
        @values.each(&:freeze)
        @mapping = values.each_with_object({}) { |v, h| h[values.index(v)] = v }.freeze
      end

      # @param [Object] input
      # @return [Object]
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
