require 'dry/logic/rule_compiler'
require 'dry/logic/predicates'

module Dry
  module Data
    def self.Rule(primitive, options)
      rule_compiler.(
        options.map { |key, val|
          [:val, [primitive, [:predicate, [:"#{key}?", [val]]]]]
        }
      ).reduce(:and)
    end

    def self.rule_compiler
      @rule_compiler ||= Logic::RuleCompiler.new(Logic::Predicates)
    end
  end
end
