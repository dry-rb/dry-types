require 'concurrent/map'

module Dry
  module Types
    module Cache
      def self.extended(klass)
        super
        klass.include(Methods)
        klass.instance_variable_set(:@__cache__, Concurrent::Map.new)
      end

      def cache
        @__cache__
      end

      def fetch_or_store(*args, &block)
        cache.fetch_or_store(args.hash, &block)
      end

      module Methods
        def fetch_or_store(*args, &block)
          self.class.fetch_or_store(*args, &block)
        end
      end
    end
  end
end
