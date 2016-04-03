RSpec.describe Dry::Types::Definition do
  describe 'json.nil' do
    subject(:type) { Dry::Types['json.nil'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it is not an empty string' do
      expect(type[['foo']]).to eql(['foo'])
    end
  end

  describe 'json.date' do
    subject(:type) { Dry::Types['json.date'] }

    it 'coerces to a date' do
      expect(type['2015-11-26']).to eql(Date.new(2015, 11, 26))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date']).to eql('not-a-date')
    end
  end

  describe 'json.date_time' do
    subject(:type) { Dry::Types['json.date_time'] }

    it 'coerces to a date time' do
      expect(type['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date-time']).to eql('not-a-date-time')
    end
  end

  describe 'json.time' do
    subject(:type) { Dry::Types['json.time'] }

    it 'coerces to a time' do
      expect(type['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-time']).to eql('not-a-time')
    end
  end

  describe 'json.decimal' do
    subject(:type) { Dry::Types['json.decimal'] }

    it 'coerces empty string to nil' do
      expect(type['']).to eql(nil)
    end

    it 'coerces strings to a decimal' do
      expect(type['3.12']).to eql(BigDecimal('3.12'))
    end

    it 'coerces floats to a decimal' do
      expect(type[3.12]).to eql(BigDecimal('3.12'))
    end
  end

  describe 'json.array' do
    subject(:type) { Dry::Types['json.array'].member(Dry::Types['int']) }

    it 'returns original value when it is not an array' do
      foo = 'foo'
      expect(type[foo]).to be(foo)
    end
  end

  describe 'json.hash' do
    subject(:type) { Dry::Types['json.hash'].schema(age: Dry::Types['int']) }

    it 'returns original value when it is not an hash' do
      foo = 'foo'
      expect(type[foo]).to be(foo)
    end
  end
end
