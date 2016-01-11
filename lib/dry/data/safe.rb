require 'dry/data/decorator'

module Dry
  module Data
    class Safe
      include Decorator
      include TypeBuilder

      def call(input)
        if input.is_a?(primitive)
          type.call(input)
        else
          input
        end
      end
      alias_method :[], :call
    end
  end
end
