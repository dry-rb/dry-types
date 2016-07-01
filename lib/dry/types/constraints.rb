require 'dry/logic/rule_compiler'
require 'dry/logic/predicates'

module Dry
  module Types
    def self.Rule(options)
      rule_compiler.(
        options.map { |key, val| [:val, Logic::Predicates[:"#{key}?"].curry(val).to_ast] }
      ).reduce(:and)
    end

    def self.rule_compiler
      @rule_compiler ||= Logic::RuleCompiler.new(Logic::Predicates)
    end
  end
end
