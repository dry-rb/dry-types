RSpec.describe Dry::Types::Definition, '#default' do
  context 'with a definition' do
    subject(:type) { Dry::Types['string'].default('foo') }

    it_behaves_like Dry::Types::Definition

    it 'returns default value when no value is passed' do
      expect(type[]).to eql('foo')
    end

    it 'aliases #[] as #call' do
      expect(type.call).to eql('foo')
    end

    it 'returns original value when it is not nil' do
      expect(type['bar']).to eql('bar')
    end

    it 'returns default value when nil is passed too' do
      expect(type[nil]).to eql('foo')
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

  context 'with meta attributes' do
    context 'default called first' do
      subject(:type) { Dry::Types['hash'].default({}).meta(omittable: true) }

      it_behaves_like 'Dry::Types::Definition without primitive'

      it 'allows nil' do
        expect(type[]).to eq({})
      end
    end

    context 'default called last' do
      subject(:type) { Dry::Types['hash'].meta(omittable: true).default({}) }

      it_behaves_like 'Dry::Types::Definition without primitive'

      it 'allows nil' do
        expect(type[]).to eq({})
      end
    end
  end

  context 'with an optional type' do
    subject(:type) { Dry::Types['strict.integer'].optional.default(nil) }

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'allows nil' do
      expect(type[nil]).to be(nil)
    end
  end

  context 'with a strict bool' do
    subject(:type) { Dry::Types['strict.bool'] }

    it_behaves_like 'Dry::Types::Definition without primitive' do
      let(:type) { Dry::Types['strict.bool'].default(false) }
    end

    it 'allows setting false' do
      expect(type.default(false).call).to be(false)
    end

    it 'allows setting true' do
      expect(type.default(true).call).to be(true)
    end
  end

  context 'with a callable value' do
     context 'with 0-arity block' do
      subject(:type) { Dry::Types['time'].default { Time.now } }

      it_behaves_like Dry::Types::Definition

      it 'calls the value' do
        expect(type.call).to be_instance_of(Time)
      end
    end

     context 'with 1-arg block' do
      let(:floor_to_date) { -> t { Time.new(t.year, t.month, t.day) } }

      subject(:type) do
        Dry::Types['time'].constructor(&floor_to_date).default { |type| type[Time.now] }
      end

      it_behaves_like Dry::Types::Definition

      it 'can call the next type in the chain' do
        expect(type.call).to eql(floor_to_date[Time.now])
      end
    end
  end

  describe 'decorator' do
    subject(:type) { Dry::Types['strict.string'].default('foo') }

    it 'raises no-method error when type does not respond to a method' do
      expect { type.oh_noez }.to raise_error(NoMethodError, /oh_noez/)
    end
  end

  describe'#with' do
    subject(:type) { Dry::Types['time'].default { Time.now }.with(meta: { foo: :bar }) }

    it_behaves_like Dry::Types::Definition

    it 'creates a new type with provided options' do
      expect(type.options).to eql({})
      expect(type.meta).to eql(foo: :bar)
    end

    it 'calls the value' do
      expect(type.call).to be_instance_of(Time)
    end
  end

  it 'works with coercible.array' do
    base = Dry::Types['coercible.array'].default([].freeze)
    type = base.of(Dry::Types['string'])

    expect(type[]).to eql([])
  end
end
