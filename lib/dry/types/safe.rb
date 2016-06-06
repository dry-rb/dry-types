require 'dry/types/decorator'

module Dry
  module Types
    class Safe
      include Dry::Equalizer(:type, :options)
      include Decorator
      include Builder

      def call(input)
        try(input).input
      end
      alias_method :[], :call

      def try(input, &block)
        type.try(input, &block)
      rescue TypeError, ArgumentError => e
        result = failure(input, e.message)
        block ? yield(result) : result
      end

      private

      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
