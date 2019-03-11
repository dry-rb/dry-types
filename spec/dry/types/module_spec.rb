require 'spec_helper'

RSpec.describe Dry::Types::Module do
  context 'builder methods' do
    subject(:mod) { Dry::Types.module }

    describe '.Array' do
      it 'builds an array type' do
        expect(mod.Array(mod::Strict::Integer)).
          to eql(Dry::Types['array<strict.integer>'])
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
        expect(mod.Hash(age: Dry::Types['strict.integer'])).
          to eql(Dry::Types['hash'].schema(age: Dry::Types['strict.integer']))
      end
    end

    describe '.Map' do
      it 'builds a map type' do
        expected = Dry::Types::Map.new(::Hash, key_type: Dry::Types['integer'])
        expect(mod.Map(mod::Integer, 'any')).to eql(expected)
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

    describe '.Strict' do
      it 'is an alias for Instance' do
        foo_type = Class.new

        expect(mod.Strict(foo_type)).to eql(mod.Instance(foo_type))
        expect(mod.Strict(Integer)).to eql(mod::Strict::Integer)
      end
    end

    describe 'JSON' do
      it 'defines json types' do
        expect(mod::JSON::Decimal).to be(Dry::Types['json.decimal'])
      end
    end
  end

  context 'parameters' do
    subject(:mod) { Dry::Types::Module.new(Dry::Types.container, *args) }

    context 'no options' do
      let(:args) { [] }

      it 'contains all types by default' do
        expect(mod.constants.to_set).
          to be > %i(Strict Coercible Optional JSON Params Integer).to_set
      end
    end

    %i(strict coercible params json nominal).each do |ns|
      constant = Dry::Types::Inflector.camelize(ns.to_s).to_sym

      context ns.to_s do
        subject(:args) { [ns] }

        it "includes only #{ ns } types" do
          constants = mod.constants(false)
          expect(constants).to eql([constant])
          expect(mod.const_get(constant)::Decimal).
            to be(Dry::Types["#{ ns }.decimal"])
        end
      end
    end

    context 'multiple namespaces' do
      subject(:args) { [:strict, :nominal] }

      it 'adds only two constants' do
        constants = mod.constants(false)
        expect(constants.sort).to eql([:Nominal, :Strict])
      end
    end

    context 'default types' do
      context 'several namespaces with default' do
        subject(:args) { [:nominal, default: :strict] }

        it 'adds strict types as default' do
          expect(mod::Integer).to be(Dry::Types['strict.integer'])
          expect(mod::Nominal::Integer).to be(Dry::Types['integer'])
          expect { mod::Params }.to raise_error(NameError)
        end
      end

      context 'without namespaces' do
        subject(:args) { [default: :strict] }

        it 'adds all namespaces wiht strict types as default' do
          expect(mod::Integer).to be(Dry::Types['strict.integer'])
          expect(mod::Nominal::Integer).to be(Dry::Types['integer'])
        end
      end
    end

    context 'aliases' do
      subject(:mod) { Dry::Types.module(strict: :Strong) }

      it 'uses custom names for modules' do
        expect(mod.constants(false)).to eql([:Strong])
        expect(mod::Strong::Integer).to be(Dry::Types['strict.integer'])
      end
    end
  end
end
