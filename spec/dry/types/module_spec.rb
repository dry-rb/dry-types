require 'spec_helper'

RSpec.describe Dry::Types do
  subject(:mod) { Dry::Types.module }

  describe '.Array' do
    it 'builds an array type' do
      expect(mod.Array(mod::Strict::Int)).
        to eql(Dry::Types['array<strict.int>'])
    end
  end

  describe '.Instance' do
    it 'builds a definition of a class instance' do
      foo_type = Class.new

      expect(mod.Instance(foo_type)).
        to eql(Dry::Types::Definition.new(foo_type).constrained(type: foo_type))
    end
  end

  describe '.Value' do
    it 'builds a definition of a single value' do
      expect(mod.Value({})).
        to eql(Dry::Types::Definition.new(Hash).constrained(eql: {}))
    end
  end

  describe '.Constant' do
    it 'builds a definition of a constant' do
      obj = Object.new

      expect(mod.Constant(obj)).
        to eql(Dry::Types::Definition.new(Object).constrained(equal: obj))
    end
  end

  describe '.Hash' do
    it 'builds a hash schema' do
      expect(mod.Hash(:symbolized, age: Dry::Types['strict.int'])).
        to eql(Dry::Types['hash'].symbolized(age: Dry::Types['strict.int']))
    end
  end
end
