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
        input.nil? ? value : type[input]
      end
      alias_method :[], :call
    end
  end
end
