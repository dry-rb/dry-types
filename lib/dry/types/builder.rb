module Dry
  module Types
    module Builder
      include Dry::Core::Constants

      # @return [Class]
      def constrained_type
        Constrained
      end

      # @param [Type] other
      # @return [Sum, Sum::Constrained]
      def |(other)
        klass = constrained? && other.constrained? ? Sum::Constrained : Sum
        klass.new(self, other)
      end

      # @return [Sum]
      def optional
        Types['strict.nil'] | self
      end

      # @param [Hash] options constraining rule (see {Types.Rule})
      # @return [Constrained]
      def constrained(options)
        constrained_type.new(self, rule: Types.Rule(options))
      end

      # @param [Object] input
      # @param [#call,nil] block
      # @raise [ConstraintError]
      # @return [Default]
      def default(input = Undefined, &block)
        value = input == Undefined ? block : input

        if value.is_a?(Proc) || valid?(value)
          Default[value].new(self, value)
        else
          raise ConstraintError.new("default value #{value.inspect} violates constraints", value)
        end
      end

      # @param [Array] values
      # @return [Enum]
      def enum(*values)
        Enum.new(constrained(included_in: values), values: values)
      end

      # @return [Safe]
      def safe
        Safe.new(self)
      end

      # @param [#call,nil] constructor
      # @param [Hash] options
      # @param [#call,nil] block
      # @return [Constructor]
      def constructor(constructor = nil, **options, &block)
        Constructor.new(with(options), fn: constructor || block)
      end
    end
  end
end

require 'dry/types/default'
require 'dry/types/constrained'
require 'dry/types/enum'
require 'dry/types/safe'
require 'dry/types/sum'
