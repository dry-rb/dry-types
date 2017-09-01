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
        to eql(Dry::Types::Definition.new(Object).constrained(is: obj))
    end
  end

  describe '.Hash' do
    it 'builds a hash schema' do
      expect(mod.Hash(:symbolized, age: Dry::Types['strict.int'])).
        to eql(Dry::Types['hash'].symbolized(age: Dry::Types['strict.int']))
    end
  end

  describe '.Constructor' do
    it 'builds a constructor type' do
      to_s = :to_s.to_proc

      expect(mod.Constructor(String, &to_s)).
        to eql(Dry::Types::Definition.new(String).constructor(to_s))

      expect(mod.Constructor(String, to_s)).
        to eql(Dry::Types::Definition.new(String).constructor(to_s))
    end

    it 'uses .new method by default' do
      type = mod.Constructor(String)

      expect(type['foo']).to eql('foo')
      expect { type[1] }.to raise_error(TypeError)
    end
  end

  describe '.Definition' do
    it 'builds a definition type' do
      expect(mod.Definition(String)).to eql(Dry::Types::Definition.new(String))
    end
  end

  it 'defines methods when included' do
    expect(Module.new.tap { |m| m.include mod }.Definition(String)).
      to eql(mod.Definition(String))
  end
end
