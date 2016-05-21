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

  context 'with a strict bool' do
    subject(:type) { Dry::Types['strict.bool'] }

    it 'allows setting false' do
      expect(type.default(false)[nil]).to be(false)
    end

    it 'allows setting true' do
      expect(type.default(true)[nil]).to be(true)
    end
  end

  context 'with a callable value' do
    subject(:type) { Dry::Types['time'].default { Time.now } }

    it 'calls the value' do
      expect(type[nil]).to be_instance_of(Time)
    end
  end

  describe 'decorator' do
    subject(:type) { Dry::Types['strict.string'].default('foo') }

    it 'raises no-method error when type does not respond to a method' do
      expect { type.oh_noez }.to raise_error(NoMethodError, /oh_noez/)
    end
  end

  describe 'equality' do
    context 'with a static value' do
      def type
        Dry::Types['strict.string'].default('foo')
      end

      it_behaves_like 'a type with equality defined'
    end

    context 'with a callable value' do
      def type
        Dry::Types['strict.string'].default { 'foo' }
      end

      it_behaves_like 'a type with equality defined'
    end
  end
end
