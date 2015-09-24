module Dry
  module Data
    class Resolver
      def call(container, key)
        item = container.fetch(key) do
          fail Error, "Nothing registered with the key #{key.inspect}"
        end
      end
    end
  end
end
