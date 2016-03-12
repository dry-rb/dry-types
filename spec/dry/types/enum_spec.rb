RSpec.describe Dry::Types::Enum do
  context 'with string type' do
    subject(:type) { Dry::Types['string'].enum(*values) }

    let(:values) { %w(draft published archived) }
    let(:string) { Dry::Types['strict.string'] }

    it_behaves_like Dry::Types::Definition

    it 'allows defining an enum from a specific type' do
      expect(type['draft']).to eql(values[0])
      expect(type['published']).to eql(values[1])
      expect(type['archived']).to eql(values[2])

      expect(type[0]).to be(values[0])
      expect(type[1]).to be(values[1])
      expect(type[2]).to eql(values[2])

      expect(type.values).to eql(values)

      expect { type['oops'] }.to raise_error(Dry::Types::ConstraintError, /oops/)

      expect(type.values).to be_frozen
    end

    it 'allows setting a default value' do
      with_default = type.default('draft')

      expect(with_default[nil]).to eql('draft')
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
end
