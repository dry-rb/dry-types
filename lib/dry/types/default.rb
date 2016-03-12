require 'dry/types/decorator'

module Dry
  module Types
    class Default
      include Decorator
      include Builder

      attr_reader :value

      def initialize(type, options)
        super
        @value = options.fetch(:value)
      end

      def call(input)
        if input.nil?
          value
        else
          output = type[input]
          output.nil? ? value : output
        end
      end
      alias_method :[], :call
    end
  end
end
