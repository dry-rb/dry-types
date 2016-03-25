RSpec.describe Dry::Types::Definition, '#default' do
  context 'with a definition' do
    subject(:type) { Dry::Types['string'].default('foo') }

    it 'returns default value when nil is passed' do
      expect(type[nil]).to eql('foo')
    end

    it 'aliases #[] as #call' do
      expect(type.call(nil)).to eql('foo')
    end

    it 'returns original value when it is not nil' do
      expect(type['bar']).to eql('bar')
    end
  end

  context 'with a constrained type' do
    it 'does not allow a value that is not valid' do
      expect {
        Dry::Types['strict.string'].default(123)
      }.to raise_error(
        Dry::Types::ConstraintError, /123/
      )
    end
  end

  context 'with an optional type' do
    subject(:type) { Dry::Types['strict.int'].optional.default(nil) }

    it 'allows nil' do
      expect(type[nil]).to be(nil)
    end
  end

  context 'with a maybe' do
    subject(:type) { Dry::Types['strict.int'].maybe }

    it 'does not allow nil' do
      expect { type.default(nil) }.to raise_error(ArgumentError, /nil/)
    end

    it 'accepts a non-nil value' do
      expect(type.default(0)[0].value).to be(0)
    end
  end

  context 'with a callable value' do
    subject(:type) { Dry::Types['time'].default { Time.now } }

    it 'calls the value' do
      expect(type[nil]).to be_instance_of(Time)
    end
  end
end
