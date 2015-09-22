require 'bigdecimal'

require 'dry/data/version'

module Dry
  module Data
    TypeError = Class.new(StandardError)

    class Type
      attr_reader :constructor

      attr_reader :types

      def initialize(constructor, types)
        @constructor = constructor
        @types = types
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call
    end

    class DSL
      attr_reader :types

      attr_reader :registry

      def initialize(registry)
        @types = []
        @registry = registry
      end

      def [](name)
        Type.new(registry[name], registry.types(name))
      end
    end

    class Registry
      BUILT_IN = [String, Integer, Float, BigDecimal, Array, Hash].freeze

      attr_reader :index

      def initialize
        @index = BUILT_IN
          .map(&:name)
          .map(&:freeze)
          .each_with_object({}) { |name, result| result[name] = Object.method(name) }
      end

      def []=(name, constructor)
        index[name] = constructor
      end

      def [](name)
        index[name]
      end

      def types(type)
        [index.keys.detect { |name| name.equal?(type) }]
      end
    end

    def self.registry
      @registry ||= Registry.new
    end

    def self.register(name, constructor)
      registry[name] = constructor
    end

    def self.new(*args, &block)
      if block
        dsl = DSL.new(registry)
        yield(dsl)
      else
        Class.new(Type) { types(args) }
      end
    end
  end
end
