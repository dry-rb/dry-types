RSpec.shared_examples_for Dry::Types::Struct do
  let(:jane) { { name: :Jane, age: '21', root: true, address: { city: 'NYC', zipcode: 123 } } }
  let(:mike) { { name: :Mike, age: '43', root: false, address: { city: 'Atlantis', zipcode: 456 } } }
  let(:john) { { name: :John, age: '36', root: false, address: { city: 'San Francisco', zipcode: 789 } } }

  describe '#eql' do
    context 'when struct values are equal' do
      let(:user_1) { type[jane] }
      let(:user_2) { type[jane] }

      it 'returns true' do
        expect(user_1).to eql(user_2)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) { type[jane] }
      let(:user_2) { type[mike] }

      it 'returns false' do
        expect(user_1).to_not eql(user_2)
      end
    end
  end

  describe '#hash' do
    context 'when struct values are equal' do
      let(:user_1) { type[jane] }
      let(:user_2) { type[jane] }

      it 'the hashes are equal' do
        expect(user_1.hash).to eql(user_2.hash)
      end
    end

    context 'when struct values are not equal' do
      let(:user_1) { type[jane] }
      let(:user_2) { type[mike] }

      it 'the hashes are not equal' do
        expect(user_1.hash).to_not eql(user_2.hash)
      end
    end
  end

  describe '#inspect' do
    let(:user_1) { type[jane] }

    it 'lists attributes' do
      expect(user_1.inspect).to eql(
        %Q(#<#{type} name="Jane" age=21 address=#<Test::Address city="NYC" zipcode="123"> root=true>)
      )
    end
  end

  context 'class interface' do
    describe '.|' do
      let(:sum_type) { type_or_nil = type | Dry::Types['strict.nil'] }

      it 'returns Sum type' do
        expect(sum_type).to be_instance_of(Dry::Types::Sum)
        expect(sum_type[nil]).to be_nil
        expect(sum_type[jane]).to eql(type[jane])
      end
    end

    describe '.maybe?' do
      it 'is not a maybe' do
        expect(type).not_to be_maybe
      end
    end

    describe '.default?' do
      it 'is not a default' do
        expect(type).not_to be_default
      end
    end

    describe '.default' do
      let(:default_type) { type.default(type[jane]) }

      it 'retruns Default type' do
        expect(default_type).to be_instance_of(Dry::Types::Default)
        expect(default_type[nil]).to eql(type[jane])
      end
    end

    describe '.enum' do
      let(:enum_type) { type.enum(type[jane], type[mike]) }

      it 'returns Enum type' do
        expect(enum_type[type[jane]]).to eql(type[jane])
        expect { enum_type[type[john]] }.to raise_error(Dry::Types::ConstraintError)
      end
    end

    describe '.optional' do
      let(:optional_type) { type.optional }

      it 'returns Sum type' do
        expect(optional_type).to eql(Dry::Types['strict.nil'] | type)
        expect(optional_type[nil]).to be_nil
        expect(optional_type[jane]).to eql(type[jane])
      end
    end
  end

  it 'registered without wrapping' do
    expect(Dry::Types[type]).to be type
  end
end
