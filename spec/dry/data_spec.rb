require 'spec_helper'

RSpec.describe Dry::Data do
  describe '.register' do
    it 'registers a new type constructor' do
      class FlatArray
        def self.constructor(input)
          input.flatten
        end
      end

      Dry::Data.register(
        'custom_array',
        Dry::Data::Type.new(FlatArray.method(:constructor), Array)
      )

      input = [[1], [2]]

      expect(Dry::Data['custom_array'][input]).to eql([1, 2])
    end
  end

  describe '.register_class' do
    it 'registers a class and uses `.new` method as default constructor' do
      module Test
        User = Struct.new(:name)
      end

      Dry::Data.register_class(Test::User)

      expect(Dry::Data['test.user'].primitive).to be(Test::User)
    end
  end

  describe '.[]' do
    it 'returns registered type for "string"' do
      expect(Dry::Data['string']).to be_a(Dry::Data::Type)
      expect(Dry::Data['string'].name).to eql('String')
    end

    it 'caches dynamically built types' do
      expect(Dry::Data['array<string>']).to be(Dry::Data['array<string>'])
    end
  end

  describe '.define_constants' do
    it 'defines types under constants in the provided namespace' do
      constants = Dry::Data.define_constants(Test, ['coercible.string'])

      expect(constants).to eql([Dry::Data['coercible.string']])
      expect(Test::Coercible::String).to be(Dry::Data['coercible.string'])
    end
  end

  describe '.finalize' do
    it 'defines all registered types under configured namespace' do
      Dry::Data.configure { |config| config.namespace = Test }
      Dry::Data.finalize

      expect(Test::Strict::String).to be(Dry::Data['strict.string'])
      expect(Test::Coercible::String).to be(Dry::Data['coercible.string'])
      expect(Test::Maybe::Coercible::Int).to be(Dry::Data['maybe.coercible.int'])
    end
  end
end
