RSpec.describe Dry::Types::Constrained do
  before(:all) do
    Dry::Types.load_extensions(:maybe)
  end

  context 'with a maybe type' do
    subject(:type) do
      Dry::Types['string'].constrained(size: 4).maybe
    end

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'passes when constraints are not violated' do
      expect(type[nil].value).to be(nil)
      expect(type['hell'].value).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type['hel'] }.to raise_error(Dry::Types::ConstraintError, /hel/)
    end
  end
end
