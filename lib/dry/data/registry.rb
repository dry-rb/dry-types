module Dry
  module Data
    class Registry
      attr_reader :index

      def initialize
        @index = {}
      end

      def []=(name, args)
        index[name.freeze] = args
      end

      def [](name)
        index.fetch(name)
      end
    end
  end
end
