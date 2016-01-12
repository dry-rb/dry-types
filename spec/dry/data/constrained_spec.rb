RSpec.describe Dry::Data::Constrained do
  describe '#[]' do
    subject(:type) do
      Dry::Data['strict.string'].constrained(size: 3..12)
    end

    it 'passes when constraints are not violated' do
      expect(type['hello']).to eql('hello')
    end

    it 'raises when a given constraint is violated' do
      expect { type['he'] }.to raise_error(Dry::Data::ConstraintError, /he/)
    end

    it 'is aliased as #call' do
      expect(type.call('hello')).to eql('hello')
    end
  end

  context 'with a sum type' do
    subject(:type) do
      Dry::Data['string'].constrained(size: 4).optional
    end

    it 'passes when constraints are not violated' do
      expect(type[nil].value).to be(nil)
      expect(type['hell'].value).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type['hel'] }.to raise_error(Dry::Data::ConstraintError, /hel/)
    end
  end

  context 'with another constrained type' do
    subject(:type) do
      Dry::Data['strict.string'].constrained(size: 4)
    end

    it 'passes when constraints are not violated' do
      expect(type['hell']).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type[nil] }.to raise_error(Dry::Data::ConstraintError, /nil/)
      expect { type['hel'] }.to raise_error(Dry::Data::ConstraintError, /hel/)
    end
  end

  context 'with another complex and constrained type' do
    subject(:type) do
      Dry::Data['strict.array']
        .constrained(size: 3)
        .member(Dry::Data['coercible.string'])
    end

    it 'passes when constraints are not violated' do
      expect(type[[:foo, :bar, :baz]]).to eql(%w(foo bar baz))
    end

    it 'raises when a given constraint is violated' do
      expect { type[%w(foo bar)] }.to raise_error(Dry::Data::ConstraintError)
    end
  end
end
