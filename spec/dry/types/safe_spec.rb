RSpec.describe Dry::Types::Nominal, '#safe' do
  context 'with a coercible string' do
    subject(:type) { Dry::Types['coercible.string'].constrained(min_size: 5).safe }

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
      Dry::Types['params.hash'].schema(age: 'coercible.integer', active: 'params.bool').safe
    end

    it_behaves_like Dry::Types::Nominal

    it 'applies its types' do
      expect(type[age: '23', active: 'f']).to eql(age: 23, active: false)
    end

    it 'rescues from type-errors and returns input' do
      expect(type[age: 'wat', active: '1']).to eql(age: 'wat', active: true)
    end
  end

  describe '#to_s' do
    subject(:type) { Dry::Types['coercible.integer'].safe }

    it 'returns string representation of the type' do
      expect(type.to_s).
        to eql("#<Dry::Types[Safe<Constructor<Nominal<Integer> fn=Kernel.Integer>>]>")
    end
  end
end
