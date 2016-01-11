require 'dry/data/decorator'

require 'dry/data/type/hash'
require 'dry/data/type/array'
require 'dry/data/type/enum'
require 'dry/data/type/default'
require 'dry/data/type/constrained'

require 'dry/data/sum_type'
require 'dry/data/optional'

module Dry
  module Data
    class Type
      include Dry::Equalizer(:constructor, :options)

      attr_reader :constructor

      attr_reader :options

      attr_reader :primitive

      def self.[](primitive)
        if primitive == ::Array
          Type::Array
        elsif primitive == ::Hash
          Type::Hash
        else
          Type
        end
      end

      def self.constructor(input)
        input
      end

      def initialize(constructor, options = {})
        @constructor = constructor
        @options = options
        @primitive = options.fetch(:primitive)
      end

      def optional
        Optional.new(Data['nil'] | self)
      end

      def constrained(options)
        Constrained.new(self, rule: Data.Rule(primitive, options))
      end

      def default(value)
        Default.new(self, value: value)
      end

      def enum(*values)
        Enum.new(constrained(inclusion: values), values: values)
      end

      def name
        primitive.name
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call

      def valid?(input)
        input.is_a?(primitive)
      end

      def |(other)
        SumType.new(self, other)
      end
    end
  end
end
