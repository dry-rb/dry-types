RSpec.describe Dry::Types::Array do
  describe '#member' do
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
        subject(:array) { Dry::Types['coercible.array'].member(Dry::Types['coercible.string']) }

        include_context 'array with a member type'
      end

      context 'using a constrained type' do
        subject(:array) do
          Dry::Types['array'].member(Dry::Types['coercible.int'].constrained(gt: 2))
        end

        it 'passes values through member type' do
          expect(array[%w(3 4 5)]).to eql([3, 4, 5])
        end

        it 'raises when input is not valid' do
          expect { array[%w(1 2 3)] }.to raise_error(
            Dry::Types::ConstraintError,
            '1 violates constraints (gt?(2) failed)'
          )
        end

        it_behaves_like Dry::Types::Definition do
          subject(:type) { array }
        end
      end
    end
  end
end
