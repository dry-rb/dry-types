RSpec.describe Dry::Types::Array do
  describe '#of' do
    context 'primitive' do
      shared_context 'array with a member type' do
        it 'returns an array with correct member values' do
          expect(array[Set[1, 2, 3]]).to eql(%w(1 2 3))
        end

        it_behaves_like Dry::Types::Definition do
          subject(:type) { array }
        end
      end

      context 'using string identifiers' do
        subject(:array) { Dry::Types['coercible.array<coercible.string>'] }

        include_context 'array with a member type'
      end

      context 'using method' do
        subject(:array) { Dry::Types['coercible.array'].of(Dry::Types['coercible.string']) }

        include_context 'array with a member type'
      end

      context 'using a constrained type' do
        subject(:array) do
          Dry::Types['array'].of(Dry::Types['coercible.integer'].constrained(gt: 2))
        end

        it 'passes values through member type' do
          expect(array[%w(3 4 5)]).to eql([3, 4, 5])
        end

        it 'raises when input is not valid' do
          expect { array[%w(1 2 3)] }.to raise_error(
            Dry::Types::ConstraintError,
            '"1" violates constraints (gt?(2, 1) failed)'
          )
        end

        it_behaves_like Dry::Types::Definition do
          subject(:type) { array }
        end
      end
    end
  end

  describe '#member' do
    subject(:array) { Dry::Types['coercible.array'].member(Dry::Types['coercible.string']) }

    it 'still works though deprecated' do
      expect(array[Set[1, 2, 3]]).to eql(%w(1 2 3))
    end
  end

  describe '#valid?' do
    subject(:array) { Dry::Types['strict.array'].of(Dry::Types['strict.string']) }

    it 'detects invalid input of the completely wrong type' do
      expect(array.valid?(5)).to be(false)
    end

    it 'detects invalid input of the wrong member type' do
      expect(array.valid?([5])).to be(false)
    end

    it 'recognizes valid input' do
      expect(array.valid?(['five'])).to be(true)
    end
  end

  describe '#===' do
    subject(:array) { Dry::Types['strict.array'].of(Dry::Types['strict.string']) }

    it 'returns boolean' do
      expect(array.===(%w(hello world))).to eql(true)
      expect(array.===(['hello', 1234])).to eql(false)
    end

    context 'in case statement' do
      let(:value) do
        case %w(hello world)
        when array then 'accepted'
          else 'invalid'
        end
      end

      it 'returns correct value' do
        expect(value).to eql('accepted')
      end
    end
  end
end
