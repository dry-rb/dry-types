RSpec.describe Dry::Types do
  describe '.register' do
    it 'registers a new type constructor' do
      module Test
        module FlatArray
          def self.constructor(input)
            input.flatten
          end
        end
      end

      Dry::Types.register(
        'custom_array',
        Dry::Types::Definition.new(Array).constructor(Test::FlatArray.method(:constructor))
      )

      input = [[1], [2]]

      expect(Dry::Types['custom_array'][input]).to eql([1, 2])
    end
  end

  describe '.[]' do
    before do
      module Test
        class Foo < Dry::Types::Definition
          def self.[](value)
            value
          end
        end
      end
    end

    let(:unregistered_type) { Test::Foo }

    it 'returns registered type for "string"' do
      expect(Dry::Types['string']).to be_a(Dry::Types::Definition)
      expect(Dry::Types['string'].name).to eql('String')
    end

    it 'caches dynamically built types' do
      expect(Dry::Types['array<string>']).to be(Dry::Types['array<string>'])
    end

    it 'returns unregistered types back' do
      expect(Dry::Types[unregistered_type]).to be(unregistered_type)
    end
  end

  describe '.module' do
    it 'returns a module with built-in types' do
      mod = Dry::Types.module

      expect(mod::Coercible::String).to be_instance_of(Dry::Types::Constructor)
    end
  end

  describe '.define_constants' do
    it 'defines types under constants in the provided namespace' do
      constants = Dry::Types.define_constants(Test, ['coercible.string'])

      expect(constants).to eql([Dry::Types['coercible.string']])
      expect(Test::Coercible::String).to be(Dry::Types['coercible.string'])
    end
  end

  describe 'missing constant' do
    it 'raises a nice error when a constant like Coercible or Strict is missing' do
      expect {
        Dry::Types::Strict::String
      }.to raise_error(NameError, /dry-types does not define constants for default types/)
    end
  end
end
