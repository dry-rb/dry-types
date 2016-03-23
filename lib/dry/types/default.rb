require 'dry/types/decorator'

module Dry
  module Types
    class Default
      include Decorator
      include Builder

      class Callable < Default
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

      def initialize(type, options)
        super
        @value = options.fetch(:value)
      end

      def constrained(*args)
        type.constrained(*args).default(value)
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
