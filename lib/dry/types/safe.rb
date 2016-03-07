require 'dry/types/decorator'

module Dry
  module Types
    class Safe
      include Decorator
      include Builder

      def call(input)
        if input.is_a?(primitive)
          type.call(input)
        else
          input
        end
      end
      alias_method :[], :call

      private

      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
