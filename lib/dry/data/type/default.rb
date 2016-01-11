module Dry
  module Data
    class Type
      class Default < Type
        include Decorator

        attr_reader :value

        def initialize(type, options)
          super
          @value = options.fetch(:value)
        end

        def call(input)
          input.nil? ? value : type[input]
        end
        alias_method :[], :call
      end
    end
  end
end
