RSpec.describe Dry::Types::Constrained do
  describe 'common definition behavior' do
    subject(:type) { Dry::Types['strict.string'].constrained(size: 3..12) }

    it_behaves_like Dry::Types::Definition
  end

  describe '#[]' do
    subject(:type) do
      Dry::Types['strict.string'].constrained(size: 3..12)
    end

    it 'passes when constraints are not violated' do
      expect(type['hello']).to eql('hello')
    end

    it 'raises when a given constraint is violated' do
      expect { type['he'] }.to raise_error(
        Dry::Types::ConstraintError,
        '"he" violates constraints (size?(3..12, "he") failed)'
      )
    end

    it 'is aliased as #call' do
      expect(type.call('hello')).to eql('hello')
    end
  end

  describe '#===' do
    subject(:type) do
      Dry::Types['strict.string'].constrained(size: 3..12)
    end

    it 'return boolean' do
      expect(type.===('hello')).to eq true
      expect(type.===('no')).to eq false
    end

    context 'In case statement' do
      let(:value) do
        case 'awesome'
          when type then 'accepted'
          else 'invalid'
        end
      end

      it 'will return correct value' do
        expect(value).to eq 'accepted'
      end
    end
  end

  context 'with a constructor type' do
    subject(:type) do
      Dry::Types['coercible.hash'].constrained(size: 1)
    end

    it_behaves_like Dry::Types::Definition

    it 'passes when constraints are not violated by the coerced value' do
      expect(type[a: 1]).to eql(a: 1)
    end

    it 'fails when constraints are violated by coerced value' do
      expect { type[{}] }.to raise_error(
        Dry::Types::ConstraintError,
        '{} violates constraints (size?(1, {}) failed)'
      )
    end

    it 'fails when coercion fails' do
      expect { type['foo'] }.to raise_error(Dry::Types::ConstraintError, /foo/)
    end
  end

  context 'with an optional sum type' do
    subject(:type) do
      Dry::Types['string'].constrained(size: 4).optional
    end

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'passes when constraints are not violated' do
      expect(type[nil]).to be(nil)
      expect(type['hell']).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type['hel'] }.to raise_error(Dry::Types::ConstraintError, /hel/)
    end
  end

  context 'with another constrained type' do
    subject(:type) do
      Dry::Types['strict.string'].constrained(size: 4)
    end

    it_behaves_like Dry::Types::Definition

    it 'passes when constraints are not violated' do
      expect(type['hell']).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type[nil] }.to raise_error(Dry::Types::ConstraintError, /nil/)
      expect { type['hel'] }.to raise_error(Dry::Types::ConstraintError, /hel/)
    end
  end

  context 'with another complex and constrained type' do
    subject(:type) do
      Dry::Types['strict.array']
        .constrained(size: 3)
        .member(Dry::Types['coercible.string'])
    end

    it_behaves_like Dry::Types::Definition

    it 'passes when constraints are not violated' do
      expect(type[[:foo, :bar, :baz]]).to eql(%w(foo bar baz))
    end

    it 'raises when a given constraint is violated' do
      expect { type[%w(foo bar)] }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
