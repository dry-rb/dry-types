module Dry
  module Data
    class Optional
      include Decorator

      def call(input)
        Maybe(type[input])
      end
      alias_method :[], :call
    end
  end
end
