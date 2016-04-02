RSpec.shared_examples_for Dry::Types::Struct do
  describe '#eql' do
    context 'when struct values are equal' do
      let(:user_1) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      let(:user_2) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      it 'returns true' do
        expect(user_1).to eql(user_2)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      let(:user_2) do
        type[
          name: :Mike, age: '43', root: false, address: { city: 'Atlantis', zipcode: 456 }
        ]
      end

      it 'returns false' do
        expect(user_1).to_not eql(user_2)
      end
    end
  end

  describe '#hash' do
    context 'when struct values are equal' do
      let(:user_1) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      let(:user_2) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      it 'the hashes are equal' do
        expect(user_1.hash).to eql(user_2.hash)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) do
        type[
          name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
        ]
      end

      let(:user_2) do
        type[
          name: :Mike, age: '43', root: false, address: { city: 'Atlantis', zipcode: 456 }
        ]
      end

      it 'the hashes are not equal' do
        expect(user_1.hash).to_not eql(user_2.hash)
      end
    end
  end

  describe '#inspect' do
    let(:user_1) do
      type[
        name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 }
      ]
    end

    it 'lists attributes' do
      expect(user_1.inspect).to eql(
        %Q(#<#{type.primitive} name="Jane" age=21 address=#<Test::Address city="NYC" zipcode="123"> root=true>)
      )
    end
  end
end
