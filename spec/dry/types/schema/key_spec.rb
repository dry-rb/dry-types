RSpec.describe Dry::Types::Hash::Key do
  let(:key) { described_class.new(Dry::Types['strict.integer'], :age) }
  subject { key }

  describe '#required' do
    it 'is true by required' do
      expect(key.required).to be true
    end

    it 'can make required key optional' do
      expect(key.required(false)).not_to be_required
    end

    describe 'optional key' do
      let(:key) { super().with(required: false) }

      it 'can make key required' do
        expect(key.required(true)).to be_required
      end
    end
  end

  describe '#omittable' do
    it 'makes key not required' do
      expect(key.omittable).not_to be_required
    end
  end
end
