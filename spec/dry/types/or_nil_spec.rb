# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal, '#lax' do
  context 'with a coercible string' do
    subject(:type) { Dry::Types['coercible.string'].constrained(min_size: 5).or_nil }

    it 'rescues from type-errors and returns nil' do
      expect(type['pass']).to eql(nil)
    end

    it 'tries to apply its type' do
      expect(type[:passing]).to eql('passing')
    end

    it 'aliases #[] as #call' do
      expect(type.method(:call)).to eql(type.method(:[]))
    end
  end

  context 'with a params hash' do
    subject(:type) do
      Dry::Types['params.hash'].schema(
        age: 'coercible.integer', active: 'params.bool', name: Dry::Types['strict.string'].or_nil
      ).or_nil
    end

    it 'applies its types' do
      expect(type[age: '23', active: 'f', name: 'jon']).to eql(age: 23, active: false, name: 'jon')
    end

    it 'rescues from type-errors and returns nil' do
      expect(type[age: 'wat', active: '1', name: 'jon']).to be_nil
    end

    it 'allows failures on the values and treats them as nil' do
      expect(type[age: '23', active: 't', name: 123]).to eql(age: 23, active: true, name: nil)
    end

    it "doesn't decorate keys" do
      expect(type.key(:age)).to be_a(Dry::Types::Schema::Key)
      expect(type.key(:age).('23')).to eql(23)
    end
  end

  context 'with an array' do
    let(:source_type) { Dry::Types['array'].of(Dry::Types['coercible.integer']) }

    subject(:type) { source_type.or_nil }

    it 'rescues from type-errors and returns nil' do
      expect(type[['1', :a, 30]]).to eql(nil)
    end

    it 'preserves meta' do
      expect(source_type.meta(foo: :bar).or_nil.meta).to eql(foo: :bar)
    end
  end

  context 'with an array member' do
    let(:type) { Dry::Types['array'].of(Dry::Types['coercible.integer'].or_nil) }

    it 'rescues from type-errors and returns nil' do
      expect(type[['1', :a, 30]]).to eql([1, nil, 30])
    end
  end

  context 'with a nominal' do
    let(:type) { Dry::Types['nominal.integer'].or_nil }

    it 'rescues from type-errors and returns nil' do
      expect(type[:a]).to eql(nil)
    end
  end

  context 'with a constructor type' do
    let(:type) { Dry::Types['json.date_time'].or_nil }

    it 'rescues from type-errors and returns nil' do
      expect(type['abc']).to eql(nil)
    end

    it 'resolves properly to the underlying type' do
      expect(type[Time.now.iso8601]).to respond_to(:iso8601)
    end
  end

  describe '#to_s' do
    subject(:type) { Dry::Types['nominal.integer'].or_nil }

    it 'returns string representation of the type' do
      expect(type.to_s).to eql("#<Dry::Types[OrNil<Constrained<Nominal<Integer> rule=[type?(Integer)]>>]>")
    end
  end

  describe '#try' do
    subject(:type) { Dry::Types['coercible.integer'].or_nil }

    it 'delegates to underlying type' do
      expect(type.try('1')).to be_a(Dry::Types::Result::Success)
      expect(type.try('a')).to be_a(Dry::Types::Result::Failure)
    end
  end

  describe '#or_nil' do
    subject(:type) { Dry::Types['coercible.integer'].or_nil }

    specify do
      expect(type.or_nil).to be(type)
    end
  end
end
