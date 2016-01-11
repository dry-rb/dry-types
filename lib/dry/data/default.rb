require 'dry/data/decorator'

module Dry
  module Data
    class Default
      include Decorator
      include TypeBuilder

      attr_reader :value

      def initialize(type, options)
        super
        @value = options.fetch(:value)
      end

      def call(input)
        input.nil? ? value : type[input]
      end
      alias_method :[], :call
    end
  end
end
