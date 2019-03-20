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

      custom_array = Dry::Types::Nominal.new(Array).constructor(Test::FlatArray.method(:constructor))

      input = [[1], [2]]

      expect(custom_array[input]).to eql([1, 2])
    end
  end

  describe '.[]' do
    before do
      module Test
        class Foo < Dry::Types::Nominal
          def self.[](value)
            value
          end
        end
      end
    end

    let(:unregistered_type) { Test::Foo }

    it 'returns registered type for "string"' do
      expect(Dry::Types['nominal.string']).to be_a(Dry::Types::Nominal)
      expect(Dry::Types['nominal.string'].name).to eql('String')
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

  describe 'missing constant' do
    it 'raises a nice error when a constant like Coercible or Strict is missing' do
      expect {
        Dry::Types::Strict::String
      }.to raise_error(NameError, /dry-types does not define constants for default types/)
    end
  end
end
