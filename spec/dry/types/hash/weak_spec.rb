RSpec.describe Dry::Types::Hash do
  subject(:hash) { Dry::Types['strict.hash'].weak(name: Dry::Types['strict.string']) }

  context 'with a Hash descendant object' do
    let(:custom_hash) { Class.new(Hash).new }
    let(:valid_hash) { custom_hash.merge(name: 'Jane') }
    let(:invalid_hash) { custom_hash.merge(name: nil) }

    describe '#[]' do
      it 'passes with a valid hash-like object' do
        expect(hash[valid_hash]).to eql(valid_hash)
      end

      it 'raises constraint error with an invalid hash-like object' do
        expect { hash[invalid_hash] }.to raise_error(Dry::Types::ConstraintError, /name/)
      end
    end

    describe '#try' do
      it 'returns a successful result with a valid hash-like object' do
        expect(hash.try(valid_hash)).to be_success
      end

      it 'returns a failure result with an invalid hash-like object' do
        expect(hash.try(invalid_hash)).to be_failure
      end
    end
  end
end
