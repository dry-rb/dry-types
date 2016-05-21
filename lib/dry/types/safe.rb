require 'dry/types/decorator'

module Dry
  module Types
    class Safe
      include Dry::Equalizer(:type, :options)
      include Decorator
      include Builder

      def call(input)
        if type.primitive?(input) || type.is_a?(Sum) || type.is_a?(Constructor)
          type[input]
        else
          input
        end
      rescue TypeError
        input
      end
      alias_method :[], :call

      def try(input, &block)
        type.try(input, &block)
      end

      private

      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
