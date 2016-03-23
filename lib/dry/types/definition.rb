require 'dry/types/builder'
require 'dry/types/result'

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

require 'dry/types/definition/array'
require 'dry/types/definition/hash'
