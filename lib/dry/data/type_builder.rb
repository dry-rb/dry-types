module Dry
  module Data
    module TypeBuilder
      def |(other)
        SumType.new(self, other)
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
    end
  end
end

require 'dry/data/default'
require 'dry/data/constrained'
require 'dry/data/enum'
require 'dry/data/optional'
require 'dry/data/sum_type'
