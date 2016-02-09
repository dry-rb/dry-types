require 'dry/logic/rule_compiler'
require 'dry/logic/predicates'

module Dry
  module Types
    module Predicates
      include Logic::Predicates

      predicate(:type?) do |type, value|
        value.kind_of?(type)
      end
    end

    def self.Rule(primitive, options)
      rule_compiler.(
        options.map { |key, val| [:val, [:predicate, [:"#{key}?", [val]]]] }
      ).reduce(:and)
    end

    def self.rule_compiler
      @rule_compiler ||= Logic::RuleCompiler.new(Types::Predicates)
    end
  end
end
