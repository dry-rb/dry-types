require 'dry/types/decorator'

module Dry
  module Types
    class Optional
      include Decorator
      include Builder

      def call(input)
        input.nil? ? input : type[input]
      end
      alias_method :[], :call
    end
  end
end
