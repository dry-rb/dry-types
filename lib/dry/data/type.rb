require 'dry/data/type/hash'
require 'dry/data/type/array'
require 'dry/data/type_builder'

module Dry
  module Data
    class Type
      include Dry::Equalizer(:constructor, :options)
      include TypeBuilder

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

      def name
        primitive.name
      end

      def call(input)
        constructor[input]
      end
      alias_method :[], :call

      def try(input)
        call(input)
      end

      def valid?(input)
        input.is_a?(primitive)
      end
    end
  end
end
