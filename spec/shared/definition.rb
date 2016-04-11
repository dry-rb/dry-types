shared_examples_for Dry::Types::Definition do
  describe '#primitive' do
    it 'returns a class' do
      expect(type.primitive).to be_instance_of(Class)
    end
  end
end

shared_examples_for 'Dry::Types::Definition#meta' do
  describe '#meta' do
    it 'allows setting meta information' do
      with_meta = type.meta(foo: :bar).meta(baz: '1')

      expect(with_meta).to be_instance_of(type.class)
      expect(with_meta.meta).to eql(foo: :bar, baz: '1')
    end
  end
end
