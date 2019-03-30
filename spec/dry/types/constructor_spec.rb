RSpec.describe Dry::Types::Constructor do
  subject(:type) do
    Dry::Types::Constructor.new(Dry::Types['nominal.string'], fn: Kernel.method(:String))
  end

  it_behaves_like Dry::Types::Nominal
  it_behaves_like 'a constrained type' do
    let(:type) { Dry::Types['string'].constructor { |x| x } }
  end

  describe '.new' do
    it 'wraps primitive in a nominal' do
      type = Dry::Types::Constructor.new(String, fn: Kernel.method(:String))

      expect(type.primitive).to be(String)
    end

    it 'passes builder types as its type' do
      type = Dry::Types::Constructor.new(Dry::Types['strict.string'], fn: -> v { v.strip })

      expect(type.type).to be(Dry::Types['strict.string'])
    end

    it 'allows block as the fn' do
      type = Dry::Types::Constructor.new(String, &:strip)

      expect(type[' foo ']).to eql('foo')
    end

    it 'throws an error if no block given' do
      expect {
        Dry::Types::Constructor.new(String)
      }.to raise_error(ArgumentError)
    end
  end

  describe '#valid?' do
    it 'returns boolean' do
      expect(type.valid?('hello')).to eql(true)
    end

    context 'fn makes invalid input valid' do
      it 'returns true' do
        expect(type.valid?(nil)).to eql(true)
      end
    end

    it 'returns boolean for invalid integer' do
      type = Dry::Types['coercible.integer']

      expect(type.valid?('hello')).to eql(false)
    end

    context 'fn raises NoMethodError' do
      let(:type) { Dry::Types::Constructor.new(String, &:strip) }

      it 'returns false' do
        expect(type.valid?(nil)).to eql(false)
      end
    end

    context 'fn raises TypeError' do
      let(:type) do
        array = [1, 2, 3]
        Dry::Types::Constructor.new(String) { |x| array[x + 1].to_s }
      end

      it 'returns false' do
        expect(type.valid?('one')).to eql(false)
      end
    end

    context 'fn raises ArgumentError' do
      let(:type) do
        Dry::Types::Constructor.new(String) { |x| Integer(x) }
      end

      it 'returns false' do
        expect(type.valid?('one')).to eql(false)
      end
    end

    context 'in case statement' do
      let(:value) do
        case 'world'
        when type then 'accepted'
          else 'invalid'
        end
      end

      it 'returns correct value' do
        expect(value).to eql('accepted')
      end
    end
  end

  describe '#call' do
    it 'uses constructor function to process input' do
      expect(type[:foo]).to eql('foo')
    end

    describe 'not safe constructor' do
      let(:type) { Dry::Types['nominal.integer'].constructor { |x| Integer(x) } }
      let(:fallback) { Object.new }

      it 'accepts block which is used as a fallback value' do
        expect(type.(:foo) { fallback }).to be(fallback)
      end
    end
  end

  describe '#primitive' do
    it 'delegates to its nominal' do
      expect(type.primitive).to be(String)
    end
  end

  describe '#constructor' do
    it 'returns a new constructor' do
      upcaser = type.constructor(-> s { s.upcase }, id: :upcaser)

      expect(upcaser[:foo]).to eql('FOO')
      expect(upcaser.options[:id]).to be(:upcaser)
    end

    it 'accepts a block' do
      upcaser = type.constructor(id: :upcaser, &:upcase)

      expect(upcaser[:foo]).to eql('FOO')
      expect(upcaser.options[:id]).to be(:upcaser)
    end
  end

  describe '#constrained?' do
    subject(:type) { Dry::Types['nominal.string'] }

    it 'returns true when its type is constrained' do
      expect(type.constrained(type: String).constructor(&:to_s)).to be_constrained
    end

    it 'returns true when its type is constrained' do
      expect(type.constructor(&:to_s)).to_not be_constrained
    end
  end

  context 'decoration' do
    subject(:type) { Dry::Types['coercible.hash'] }

    it 'responds to type methods' do
      expect(type).to respond_to(:schema)
    end

    it 'returns response when it is not a type nominal' do
      expect(type.constrained(type: Hash).rule).to be_kind_of(Dry::Logic::Rule)
    end

    it 'raises no-method error when it does not respond to a method' do
      expect { type.oh_noez }.to raise_error(NoMethodError)
    end

    it "doesn't wrap not composable types" do
      schema = type.schema(age: 'strict.integer').constructor { |input| input.transform_keys(&:to_sym) }
      expect(schema.key(:age)).to be_a(Dry::Types::Schema::Key)
    end

    it 'chooses the right constructor types' do
      sum = type.schema(age: 'strict.integer').optional
      schema = sum.constructor { |input| input.transform_keys(&:to_sym) if input }
      expect(schema.right.key(:age)).to be_a(Dry::Types::Schema::Key)
    end
  end

  describe 'equality' do
    subject(:type) { Dry::Types['nominal.string'] }

    it 'counts .fn' do
      to_i = :to_i.to_proc
      to_s = :to_s.to_proc

      expect(type.constructor(to_i)).to eq(type.constructor(to_i))
      expect(type.constructor(to_i)).not_to eq(type.constructor(to_s))

      expect(type.constructor(to_i)).to eql(type.constructor(to_i))
      expect(type.constructor(to_i)).not_to eql(type.constructor(to_s))
    end

    it 'counts meta' do
      to_i = :to_i.to_proc

      expect(type.constructor(to_i).meta(pos: :left)).to eql(type.constructor(to_i).meta(pos: :left))
      expect(type.constructor(to_i).meta(pos: :left)).not_to eql(type.constructor(to_i).meta(pos: :right))
    end
  end

  describe '#name' do
    subject(:type) { Dry::Types['nominal.string'].optional.constructor(-> v { v.nil? ? nil : v.to_s }) }

    it 'works with sum types' do
      expect(type.name).to eql('NilClass | String')
    end
  end

  describe '#try' do
    subject(:type) { Dry::Types['coercible.integer'] }

    it 'rescues ArgumentError' do
      expect(type.try('foo')).to be_failure
    end
  end

  describe '#prepend' do
    subject(:type) { Dry::Types['coercible.integer'] }

    it 'prepends the constructor' do
      expect(type.prepend(-> s { s.ord })['foo']).to eql(102)
    end

    it 'accepts block' do
      prepended = type.prepend(id: 'named') { |s| s.ord }

      expect(prepended['foo']).to eql(102)
      expect(prepended.options).to include(id: 'named')
    end
  end

  describe '#append' do
    subject(:type) { Dry::Types['coercible.integer'] }

    it 'is an alias for #constructor' do
      expect(type.method(:append)).to eql(type.method(:constructor))
    end
  end

  describe '#<<' do
    subject(:type) { Dry::Types['coercible.integer'] }

    it 'is an alias for #prepend' do
      expect(type.method(:<<)).to eql(type.method(:prepend))
    end
  end

  describe '#>>' do
    subject(:type) { Dry::Types['coercible.integer'] }

    it 'is an alias for #append' do
      expect(type.method(:>>)).to eql(type.method(:append))
    end
  end

  describe '#to_s' do
    context 'method object' do
      subject(:type) { Dry::Types['coercible.integer'] }

      it 'returns string representation of the type' do
        expect(type.to_s).
          to eql("#<Dry::Types[Constructor<Nominal<Integer> fn=Kernel.Integer>]>")
      end
    end

    context 'callable object with .call defined in class' do
      before do
        class Test::IntegerConstructor
          def call
            5
          end
        end
      end

      subject(:type) { Dry::Types['nominal.integer'].constructor(Test::IntegerConstructor.new) }

      it 'returns string representation of the type' do
        expect(type.to_s).
          to eql("#<Dry::Types[Constructor<Nominal<Integer> fn=Test::IntegerConstructor#call>]>")
      end
    end
  end
end
