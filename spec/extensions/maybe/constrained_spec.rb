# frozen_string_literal: true

RSpec.describe Dry::Types::Constrained, :maybe do
  context 'with a maybe type' do
    subject(:type) do
      Dry::Types['nominal.string'].constrained(size: 4).maybe
    end

    it_behaves_like 'Dry::Types::Nominal without primitive'

    it 'passes when constraints are not violated' do
      expect(type[nil].value).to be(nil)
      expect(type['hell'].value).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type['hel'] }.to raise_error(Dry::Types::ConstraintError, /hel/)
    end
  end
end
