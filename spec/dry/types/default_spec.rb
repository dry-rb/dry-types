# frozen_string_literal: true

RSpec.describe Dry::Types::Builder, '#default' do
  context 'with a nominal type' do
    subject(:type) { Dry::Types['nominal.string'].default('foo') }

    it_behaves_like Dry::Types::Nominal

    it 'returns default value when no value is passed' do
      expect(type[]).to eql('foo')
    end

    it 'aliases #[] as #call' do
      expect(type.call).to eql('foo')
    end

    it 'returns original value when it is not nil' do
      expect(type['bar']).to eql('bar')
    end

    it 'does not return default value when nil is passed' do
      expect(type[nil]).to eql(nil)
    end
  end

  context 'with a constrained type' do
    subject(:type) { Dry::Types['string'].default('foo') }

    it_behaves_like 'a constrained type'
  end

  context 'with a constrained type' do
    it 'does not allow a value that is not valid' do
      expect {
        Dry::Types['string'].default(123)
      }.to raise_error(
        Dry::Types::ConstraintError, /123/
      )
    end
  end

  context 'with meta attributes' do
    context 'default called first' do
      subject(:type) { Dry::Types['nominal.hash'].default({}.freeze).meta(required: false) }

      it_behaves_like 'Dry::Types::Nominal without primitive'

      it 'allows nil' do
        expect(type[]).to eq({})
      end
    end

    context 'default called last' do
      subject(:type) { Dry::Types['nominal.hash'].meta(required: false).default({}.freeze) }

      it_behaves_like 'Dry::Types::Nominal without primitive'

      it 'allows nil' do
        expect(type[]).to eq({})
      end
    end
  end

  context 'with an optional type' do
    subject(:type) { Dry::Types['integer'].optional.default(nil) }

    it_behaves_like 'Dry::Types::Nominal without primitive'

    it 'allows nil' do
      expect(type[nil]).to be(nil)
    end
  end

  context 'with strict bool' do
    subject(:type) { Dry::Types['bool'] }

    it_behaves_like 'Dry::Types::Nominal without primitive' do
      let(:type) { Dry::Types['bool'].default(false) }
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
      subject(:type) { Dry::Types['nominal.time'].default { Time.now } }

      it_behaves_like Dry::Types::Nominal

      it 'calls the value' do
        expect(type.call).to be_instance_of(Time)
      end
    end

    context 'with 1-arg block' do
      let(:floor_to_date) { -> t { Time.new(t.year, t.month, t.day) } }

      subject(:type) do
        Dry::Types['nominal.time'].constructor(&floor_to_date).default { |type| type[Time.now] }
      end

      it_behaves_like Dry::Types::Nominal

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

  describe '#with' do
    subject(:type) { Dry::Types['nominal.time'].default { Time.now }.meta(foo: :bar) }

    it_behaves_like Dry::Types::Nominal

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
    type = base.of(Dry::Types['nominal.string'])

    expect(type[]).to eql([])
  end

  it "prints warning when default value isn't frozen" do
    expect(Dry::Core::Deprecations).to receive(:warn)
    Dry::Types['nominal.string'].default('foo'.dup)
  end

  it 'discards warning when `shared` keyword is passed' do
    expect(Dry::Core::Deprecations).not_to receive(:warn)
    Dry::Types['nominal.string'].default('foo', shared: true)
  end

  describe '#valid?' do
    subject(:type) { Dry::Types['string'].default('foo') }

    it 'returns true if value is valid' do
      expect(type.valid?('bar')).to eq true
    end

    it 'returns false if value is not valid' do
      expect(type.valid?(nil)).to eq false
    end

    it 'returns true if value is Undefined' do
      expect(type.valid?(Undefined)).to eq true
    end

    it 'returns true if no value is passed' do
      expect(type.valid?).to eq true
    end
  end

  context 'with a constructor' do
    describe 'returning Undefined' do
      let(:non_empty_string) { Dry::Types['nominal.string'].constructor { |str| str.empty? ? Undefined : str } }
      subject(:type) { non_empty_string.default('empty') }

      it 'returns default value on empty input' do
        expect(type['']).to eql('empty')
      end
    end
  end

  describe '#to_s' do
    context 'static valute' do
      subject(:type) { Dry::Types['nominal.string'].default('foo') }

      it 'returns string representation of the type' do
        expect(type.to_s).to eql('#<Dry::Types[Default<Nominal<String> value="foo">]>')
      end
    end

    context 'callable value' do
      subject(:type) { Dry::Types['nominal.string'].default(value_constructor) }

      context 'proc' do
        let(:value_constructor) { proc { 'foo' } }

        let(:line_no) { value_constructor.source_location[1] }

        it 'returns string representation of the type' do
          expect(type.to_s)
            .to eql(
              '#<Dry::Types[Default<Nominal<String> '\
              "value_fn=spec/dry/types/default_spec.rb:#{line_no}>]>"
            )
        end
      end

      context 'proc w/o source' do
        let(:value_constructor) { method(:Integer).to_proc }

        it 'returns string representation of the type' do
          expect(type.to_s)
            .to eql(
              '#<Dry::Types[Default<Nominal<String> '\
              'value_fn=(lambda)>]>'
            )
        end
      end

      context 'method' do
        let(:value_constructor) { Kernel.method(:Integer) }

        it 'returns string representation of the type' do
          expect(type.to_s)
            .to eql(
              '#<Dry::Types[Default<Nominal<String> '\
              'value_fn=Kernel.Integer>]>'
            )
        end
      end

      context 'callable object' do
        let(:value_constructor) do
          obj = Object.new

          def obj.to_s
            'callable'
          end

          def obj.call(*)
            5
          end

          obj
        end

        it 'returns string representation of the type' do
          expect(type.to_s)
            .to eql(
              '#<Dry::Types[Default<Nominal<String> '\
              'value_fn=callable.call>]>'
            )
        end
      end
    end
  end

  describe '#meta' do
    subject(:type) { Dry::Types['nominal.string'].meta(foo: :bar).default('foo') }

    it 'adds uses meta from the decorated type' do
      expect(type.meta).to eql(foo: :bar)
      expect(type.meta(bar: :baz).meta).to eql(foo: :bar, bar: :baz)
    end
  end
end
