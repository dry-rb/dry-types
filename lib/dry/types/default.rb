require 'dry/types/decorator'

module Dry
  module Types
    class Default
      include Dry::Equalizer(:type, :options, :value)
      include Decorator
      include Builder

      class Callable < Default
        include Dry::Equalizer(:type, :options)

        def evaluate
          value.call
        end
      end

      attr_reader :value

      alias_method :evaluate, :value

      def self.[](value)
        if value.respond_to?(:call)
          Callable
        else
          self
        end
      end

      def initialize(type, value, options = {})
        super(type, options)
        @value = value
      end

      def constrained(*args)
        type.constrained(*args).default(value)
      end

      def default?
        true
      end

      def try(input)
        success(call(input))
      end

      def call(input)
        if input.nil?
          evaluate
        else
          output = type[input]
          output.nil? ? evaluate : output
        end
      end
      alias_method :[], :call
    end
  end
end
