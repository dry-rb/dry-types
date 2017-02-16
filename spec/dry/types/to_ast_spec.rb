require 'spec_helper'

RSpec.describe Dry::Types, '#to_ast' do
  context 'with a definition' do
    subject(:type) { Dry::Types::Definition.new(String) }

    specify do
      expect(type.to_ast).
        to eql([:definition, [:primitive, String]])
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['string'] | Dry::Types['int'] }

    specify do
      expect(type.to_ast).
        to eql([:sum, [
                  [:definition, [:primitive, String]],
                  [:definition, [:primitive, Integer]]
                ]])
    end
  end

  context 'with a constrained type' do
    subject(:type) { Dry::Types['strict.int'] }

    specify do
      expect(type.to_ast).
        to eql([:constrained, [
                  [:definition, [:primitive, Integer]],
                  [:predicate, [:type?, [[:type, Integer], [:input, Undefined]]]]
               ]])
    end
  end
end
