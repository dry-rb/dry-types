module Dry
  module Data
    class DSL
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def [](name)
        Type.new(*registry[name])
      end
    end
  end
end
