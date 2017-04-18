RSpec.shared_examples_for 'Dry::Types::Definition without primitive' do
  def be_boolean
    satisfy { |x| x == true || x == false  }
  end

  describe '#constrained?' do
    it 'returns a boolean value' do
      expect(type.constrained?).to be_boolean
    end
  end

  describe '#default?' do
    it 'returns a boolean value' do
      expect(type.default?).to be_boolean
    end
  end

  describe '#valid?' do
    it 'returns a boolean value' do
      expect(type.valid?(1)).to be_boolean
    end
  end

  describe '#eql?' do
    it 'has #eql? defined' do
      expect(type).to eql(type)
    end
  end

  describe '#==' do
    it 'has #== defined' do
      expect(type).to eq(type)
    end
  end
end

RSpec.shared_examples_for 'Dry::Types::Definition#meta' do
  describe '#meta' do
    it 'allows setting meta information' do
      with_meta = type.meta(foo: :bar).meta(baz: '1')

      expect(with_meta).to be_instance_of(type.class)
      expect(with_meta.meta).to eql(foo: :bar, baz: '1')
    end

    it "doesn't use meta in equality checks" do
      expect(type.meta(foo: :bar)).to eql(type)
      expect(type.meta(foo: :bar).hash).to eql(type.hash)
    end
  end
end

RSpec.shared_examples_for Dry::Types::Definition do
  it_behaves_like 'Dry::Types::Definition without primitive'

  describe '#primitive' do
    it 'returns a class' do
      expect(type.primitive).to be_instance_of(Class)
    end
  end
end
