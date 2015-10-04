RSpec.describe Dry::Data::Type do
  let(:string) { Dry::Data["coercible.string"] }
  let(:hash) { Dry::Data["coercible.hash"] }

  describe '#[]' do
    it 'returns input when type matches' do
      input = 'foo'
      expect(string[input]).to be(input)
    end

    it 'coerces input when type does not match' do
      input = :foo
      expect(string[input]).to eql('foo')
    end

    it 'raises type-error when coercion fails' do
      expect {
        hash['foo']
      }.to raise_error(TypeError)
    end

    it 'raises type-error when non-coercible type is used and input does not match' do
      expect { Dry::Data["strict.date"]['nopenopenope'] }
        .to raise_error(TypeError, /"nopenopenope" has invalid type/)
    end
  end

  describe 'with Bool' do
    let(:bool) { Dry::Data["strict.bool"] }

    it 'accepts true object' do
      expect(bool[true]).to be(true)
    end

    it 'accepts false object' do
      expect(bool[false]).to be(false)
    end

    it 'raises when input is not true or false' do
      expect { bool['false'] }.to raise_error(TypeError, /"false" has invalid type/)
    end
  end

  describe 'with Date' do
    let(:date) { Dry::Data["strict.date"] }

    it 'accepts a date object' do
      input = Date.new

      expect(date[input]).to be(input)
    end
  end

  describe 'with DateTime' do
    let(:datetime) { Dry::Data["strict.date_time"] }

    it 'accepts a date-time object' do
      input = DateTime.new

      expect(datetime[input]).to be(input)
    end
  end

  describe 'with Time' do
    let(:time) { Dry::Data["strict.time"] }

    it 'accepts a time object' do
      input = Time.new

      expect(time[input]).to be(input)
    end
  end

  describe 'with built-in optional types' do
    context 'with strict string' do
      let(:string) { Dry::Data["maybe.strict.string"] }

      it 'accepts nil' do
        expect(string[nil].value).to be(nil)
      end

      it 'accepts a string' do
        expect(string['something'].value).to eql('something')
      end
    end

    context 'with coercible string' do
      let(:string) { Dry::Data["maybe.coercible.string"] }

      it 'accepts nil' do
        expect(string[nil].value).to be(nil)
      end

      it 'accepts a string' do
        expect(string[:something].value).to eql('something')
      end
    end
  end

  describe 'defining coercible Optional String' do
    let(:maybe_string) { Dry::Data["strict.nil"] | Dry::Data["coercible.string"] }

    it 'accepts nil' do
      expect(maybe_string[nil].value).to be(nil)
    end

    it 'accepts an object coercible to a string' do
      expect(maybe_string[123].value).to eql('123')
    end
  end

  describe 'defining Optional String' do
    let(:maybe_string) { Dry::Data["strict.nil"] | Dry::Data["strict.string"] }

    it 'accepts nil and returns None instance' do
      value = maybe_string[nil]

      expect(value).to be_instance_of(Kleisli::Maybe::None)
      expect(value.fmap(&:downcase).fmap(&:upcase).value).to be(nil)
    end

    it 'accepts a string and returns Some instance' do
      value = maybe_string['SomeThing']

      expect(value).to be_instance_of(Kleisli::Maybe::Some)
      expect(value.fmap(&:downcase).fmap(&:upcase).value).to eql('SOMETHING')
    end
  end
end
