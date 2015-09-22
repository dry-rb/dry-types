require 'bigdecimal'
require 'date'

require 'dry/data/version'
require 'dry/data/struct'

module Dry
  module Data
    class Type
      attr_reader :constructor

      attr_reader :primitive

      def initialize(constructor, primitive)
        @constructor = constructor
        @primitive = primitive
      end

      def name
        primitive.name
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call

      def valid?(input)
        input.instance_of?(primitive)
      end

      def |(other)
        SumType.new(self, other)
      end
    end

    class SumType
      attr_reader :left

      attr_reader :right

      def initialize(left, right)
        @left, @right = left, right
      end

      def name
        [left, right].map(&:name).join(' | ')
      end

      def call(input)
        if valid?(input)
          input
        else
          raise TypeError, "#{input.inspect} has invalid type"
        end
      end
      alias_method :[], :call

      def valid?(input)
        left.valid?(input) || right.valid?(input)
      end
    end

    class DSL
      attr_reader :registry

      def initialize(registry)
        @registry = registry
      end

      def [](name)
        Type.new(*registry[name])
      end
    end

    class Registry
      BUILT_IN = [String, Integer, Float, BigDecimal, Array, Hash].freeze

      attr_reader :index

      def initialize
        @index = BUILT_IN.each_with_object({}) { |const, result|
          result[const.name.freeze] = [Object.method(const.name), const]
        }
      end

      def []=(name, args)
        index[name.freeze] = args
      end

      def [](name)
        index.fetch(name)
      end
    end

    def self.registry
      @registry ||= Registry.new
    end

    def self.register(const, constructor)
      registry[const.name] = [constructor, const]
    end

    def self.new(*args, &block)
      type = yield(DSL.new(registry))
      types[args.first || type.name] = type
    end

    def self.types
      @types ||= {}
    end

    # register built-in types that are non-coercible through kernel methods
    [TrueClass, FalseClass, Date, DateTime, Time].each do |const|
      register(const, -> input { input })
    end

    Bool = Data.new('Bool') { |t| t['TrueClass'] | t['FalseClass'] }
  end
end
