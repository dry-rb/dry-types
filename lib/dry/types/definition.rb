require 'dry/types/builder'
require 'dry/types/result'
require 'dry/types/options'

module Dry
  module Types
    class Definition
      include Dry::Equalizer(:primitive, :options)
      include Options
      include Builder

      attr_reader :options

      attr_reader :primitive

      def self.[](primitive)
        if primitive == ::Array
          Types::Array
        elsif primitive == ::Hash
          Types::Hash
        else
          self
        end
      end

      def initialize(primitive, options = {})
        super
        @primitive = primitive
        freeze
      end

      def name
        primitive.name
      end

      def call(input)
        input
      end
      alias_method :[], :call

      def try(input, &block)
        output = call(input)

        if valid?(output)
          success(output)
        else
          failure = failure(output, "#{output.inspect} must be an instance of #{primitive}")
          block ? yield(failure) : failure
        end
      end

      def success(*args)
        result(Result::Success, *args)
      end

      def failure(*args)
        result(Result::Failure, *args)
      end

      def result(klass, *args)
        klass.new(*args)
      end

      def primitive?(value)
        value.is_a?(primitive)
      end
      alias_method :valid?, :primitive?
    end
  end
end

require 'dry/types/array'
require 'dry/types/hash'
