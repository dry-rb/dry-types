RSpec.describe Dry::Types::Enum do
  context 'with mapping' do
    subject(:type) { string.enum(mapping) }

    let(:mapping) { {'draft' => 0, 'published' => 10, 'archived' => 20} }
    let(:values) { mapping.keys }
    let(:string) { Dry::Types['strict.string'] }

    it_behaves_like Dry::Types::Definition

    it 'allows defining an enum from a specific type' do
      expect(type['draft']).to eql(mapping.index(0))
      expect(type['published']).to eql(mapping.index(10))
      expect(type['archived']).to eql(mapping.index(20))

      expect(type[0]).to be(mapping.index(0))
      expect(type[10]).to be(mapping.index(10))
      expect(type[20]).to eql(mapping.index(20))

      expect(type.mapping).to eql(mapping)

      expect { type['oops'] }.to raise_error(Dry::Types::ConstraintError, /oops/)

      expect(type.mapping).to be_frozen
    end
  end

  context 'with string type' do
    subject(:type) { string.enum(*values) }

    let(:values) { %w(draft published archived) }
    let(:string) { Dry::Types['strict.string'] }

    it_behaves_like Dry::Types::Definition

    it 'allows defining an enum from a specific type' do
      expect(type['draft']).to eql(values[0])
      expect(type['published']).to eql(values[1])
      expect(type['archived']).to eql(values[2])

      expect(type[0]).to eql(values[0])
      expect(type[1]).to eql(values[1])
      expect(type[2]).to eql(values[2])

      expect(type.values).to eql(values)

      expect { type['oops'] }.to raise_error(Dry::Types::ConstraintError, /oops/)

      expect(type.values).to be_frozen
    end

    it 'allows defining an enum from a default-value type' do
      with_default = string.default('draft').enum(*values)

      expect(with_default[nil]).to eql('draft')
    end

    it 'allows defining a default value for an enum' do
      with_default = type.default('published')

      expect(with_default[nil]).to eql('published')
    end

    it 'aliases #[] as #call' do
      expect(type.call('draft')).to eql(values[0])
      expect(type.call(0)).to eql(values[0])
    end
  end

  context 'with int type' do
    subject(:type) { Dry::Types['int'].enum(*values) }

    let(:values) { [2, 3, 4] }

    it_behaves_like Dry::Types::Definition

    it 'allows defining an enum from a specific type' do
      expect(type[0]).to be(2)
      expect(type[1]).to be(3)
      expect(type[2]).to be(2)

      expect(type[2]).to be(2)
      expect(type[3]).to be(3)
      expect(type[4]).to be(4)

      expect(type.values).to eql(values)
    end
  end

  describe '#try' do
    subject(:enum) { Dry::Types['int'].enum(4, 5, 6) }

    it 'returns a success result for valid input' do
      expect(enum.try(5)).to be_success
    end

    it 'returns a failure result for invalid input' do
      expect(enum.try(2)).to be_failure
    end

    it 'accepts a block for the fallback mechanism' do
      expect(enum.try(2) { 5 }).to be(5)
    end
  end

  describe '#with' do
    subject(:enum_with_meta) { Dry::Types['int'].enum(4, 5, 6).with(meta: { foo: :bar }) }

    it_behaves_like Dry::Types::Definition do
      let(:type) { enum_with_meta }
    end

    it 'preserves metadata' do
      expect(enum_with_meta.meta).to eql(foo: :bar)
    end
  end
end
