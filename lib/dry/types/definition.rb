require 'dry/types/builder'

module Dry
  module Types
    class Definition
      include Dry::Equalizer(:primitive, :options)
      include Builder

      attr_reader :options

      attr_reader :primitive

      def self.[](primitive)
        if primitive == ::Array
          Definition::Array
        elsif primitive == ::Hash
          Definition::Hash
        else
          self
        end
      end

      def initialize(primitive, options = {})
        @primitive = primitive
        @options = options
      end

      def with(new_options)
        self.class.new(primitive, options.merge(new_options))
      end

      def name
        primitive.name
      end

      def call(input)
        input
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

require 'dry/types/definition/array'
require 'dry/types/definition/hash'
