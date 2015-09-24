module Dry
  module Data
    class Registry
      def initialize
        @_mutex = ::Mutex.new
      end

      def call(container, key, item, options)
        @_mutex.synchronize do
          if container.key?(key)
            fail Error, "There is already an item registered with the key #{key.inspect}"
          else
            container[key] = ::Dry::Data::Type.new(item, options)
          end
        end
      end
    end
  end
end
