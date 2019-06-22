# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal, '#lax' do
  context 'with a coercible string' do
    subject(:type) { Dry::Types['coercible.string'].constrained(min_size: 5).lax }

    it_behaves_like Dry::Types::Nominal

    it 'rescues from type-errors and returns input' do
      expect(type['pass']).to eql('pass')
    end

    it 'tries to apply its type' do
      expect(type[:passing]).to eql('passing')
    end

    it 'aliases #[] as #call' do
      expect(type.call(:passing)).to eql('passing')
    end
  end

  context 'with a params hash' do
    subject(:type) do
      Dry::Types['params.hash'].schema(
        age: 'coercible.integer', active: 'params.bool'
      ).lax
    end

    it_behaves_like Dry::Types::Nominal

    it 'applies its types' do
      expect(type[age: '23', active: 'f']).to eql(age: 23, active: false)
    end

    it 'rescues from type-errors and returns input' do
      expect(type[age: 'wat', active: '1']).to eql(age: 'wat', active: true)
    end

    it "doesn't decorate keys" do
      expect(type.key(:age)).to be_a(Dry::Types::Schema::Key)
      expect(type.key(:age).('23')).to eql(23)
    end
  end

  context 'with an array' do
    subject(:type) do
      Dry::Types['array'].of(Dry::Types['coercible.integer']).lax
    end

    it 'rescues from type-errors and returns input' do
      expect(type[['1', :a, 30]]).to eql([1, :a, 30])
    end
  end

  describe '#to_s' do
    subject(:type) { Dry::Types['coercible.integer'].lax }

    it 'returns string representation of the type' do
      expect(type.to_s).
        to eql("#<Dry::Types[Lax<Constructor<Nominal<Integer> fn=Kernel.Integer>>]>")
    end
  end
end
