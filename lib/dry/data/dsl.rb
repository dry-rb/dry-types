module Dry
  module Data
    class DSL
      attr_reader :container

      def initialize(container)
        @container = container
      end

      def [](name)
        container[name]
      end
    end
  end
end
