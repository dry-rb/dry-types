require 'dry/logic/rule_compiler'
require 'dry/logic/predicates'
require 'dry/logic/rule/predicate'

module Dry
  module Types
    # @param [Hash] options
    # @return [Dry::Logic::Rule]
    def self.Rule(options)
      rule_compiler.(
        options.map { |key, val| Logic::Rule::Predicate.new(Logic::Predicates[:"#{key}?"]).curry(val).to_ast }
      ).reduce(:and)
    end

    # @return [Dry::Logic::RuleCompiler]
    def self.rule_compiler
      @rule_compiler ||= Logic::RuleCompiler.new(Logic::Predicates)
    end
  end
end
