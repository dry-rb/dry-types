require 'dry-equalizer' # FIXME: this should not be needed

require 'dry/validation/rule_compiler'
require 'dry/validation/predicates'

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
      @rule_compiler ||= Validation::RuleCompiler.new(Validation::Predicates)
    end
  end
end
