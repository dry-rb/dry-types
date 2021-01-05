# frozen_string_literal: true

require "dry/types/predicate_registry"

RSpec.describe Dry::Types::PredicateRegistry do
  subject(:predicate_registry) { Dry::Types::PredicateRegistry.new }

  describe "#[]" do
    it "gives access to built-in predicates" do
      expect(predicate_registry[:filled?].("sutin")).to be(true)
    end
  end

  describe "#key?" do
    it "checks whether a predicate is registered" do
      expect(predicate_registry.key?(:respond_to?)).to be(true)
      expect(predicate_registry.key?(:nope?)).to be(false)
    end
  end
end
