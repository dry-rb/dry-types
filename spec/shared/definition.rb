shared_examples_for Dry::Types::Definition do
  describe '#primitive' do
    it 'returns a class' do
      expect(type.primitive).to be_instance_of(Class)
    end
  end
end
