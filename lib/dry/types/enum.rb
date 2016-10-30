require 'dry/types/decorator'

module Dry
  module Types
    class Enum
      include Dry::Equalizer(:type, :options, :mapping)
      include Decorator

      attr_reader :values, :mapping

      def initialize(type, options)
        super
        @mapping = options.fetch(:mapping).freeze
        @values = @mapping.keys.freeze
        @values.each(&:freeze)
      end

      def call(input)
        value =
          if mapping.key?(input)
            input
          elsif mapping.values.include?(input)
            mapping.index(input)
          end

        type[value || input]
      end
      alias_method :[], :call
    end
  end
end
