RSpec.describe Dry::Types::Nominal, :maybe do
  describe 'with opt-in maybe types' do
    context 'with strict string' do
      let(:string) { Dry::Types["maybe.strict.string"] }

      it_behaves_like 'Dry::Types::Nominal without primitive' do
        let(:type) { string }
      end

      it 'accepts nil' do
        expect(string[nil].value).to be(nil)
      end

      it 'accepts a string' do
        expect(string['something'].value).to eql('something')
      end
    end

    context 'with coercible string' do
      let(:string) { Dry::Types["maybe.coercible.string"] }

      it_behaves_like 'Dry::Types::Nominal without primitive' do
        let(:type) { string }
      end

      it 'accepts nil' do
        expect(string[nil].value).to be(nil)
      end

      it 'accepts a string' do
        expect(string[:something].value).to eql('something')
      end
    end
  end

  describe 'defining coercible Maybe String' do
    let(:maybe_string) { Dry::Types["coercible.string"].maybe }

    it_behaves_like 'Dry::Types::Nominal without primitive' do
      let(:type) { maybe_string }
    end

    it 'accepts nil' do
      expect(maybe_string[nil].value).to be(nil)
    end

    it 'accepts an object coercible to a string' do
      expect(maybe_string[123].value).to eql('123')
    end
  end

  describe 'defining Maybe String' do
    let(:maybe_string) { Dry::Types["strict.string"].maybe }

    it_behaves_like 'Dry::Types::Nominal without primitive' do
      let(:type) { maybe_string }
    end

    it 'accepts nil and returns None instance' do
      value = maybe_string[nil]

      expect(value).to be_instance_of(Dry::Monads::Maybe::None)
      expect(value.fmap(&:downcase).fmap(&:upcase).value).to be(nil)
    end

    it 'accepts a string and returns Some instance' do
      value = maybe_string['SomeThing']

      expect(value).to be_instance_of(Dry::Monads::Maybe::Some)
      expect(value.fmap(&:downcase).fmap(&:upcase).value).to eql('SOMETHING')
    end
  end
end
