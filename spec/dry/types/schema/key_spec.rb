# frozen_string_literal: true

RSpec.describe Dry::Types::Schema::Key do
  let(:key) { described_class.new(Dry::Types['integer'], :age) }

  subject { key }

  it_behaves_like Dry::Types::Nominal do
    subject(:type) { key }
  end

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

  describe '#meta' do
    it 'can make key omittable' do
      expect(key.meta(omittable: true)).not_to be_required
    end
  end

  describe '#optional' do
    let(:key) { described_class.new(Dry::Types['integer'], :age) }

    it 'makes type optional' do
      expect(key.optional).to be_optional
      expect(key.optional).to be_a(described_class)
    end
  end
end
