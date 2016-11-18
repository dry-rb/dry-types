module Dry
  module Types
    module Builder
      def constrained_type
        Constrained
      end

      def |(other)
        klass = constrained? && other.constrained? ? Sum::Constrained : Sum
        klass.new(self, other)
      end

      def optional
        Types['strict.nil'] | self
      end

      def constrained(options)
        constrained_type.new(self, rule: Types.Rule(options))
      end

      def default(input = Undefined, &block)
        value = input == Undefined ? block : input

        if value.is_a?(Proc) || valid?(value)
          Default[value].new(self, value)
        else
          raise ConstraintError.new("default value #{value.inspect} violates constraints", value)
        end
      end

      def enum(*values)
        Enum.new(constrained(included_in: values), values: values)
      end

      def safe
        Safe.new(self)
      end

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
