RSpec.describe Dry::Types::Nominal do
  describe 'params.nil' do
    subject(:type) { Dry::Types['params.nil'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it is not an empty string' do
      expect(type[['foo']]).to eql(['foo'])
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.nil | params.integer' do
    subject(:type) { Dry::Types['params.nil'] | Dry::Types['params.integer'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'coerces string to an integer' do
      expect(type['23']).to be(23)
    end
  end

  describe 'params.date' do
    subject(:type) { Dry::Types['params.date'] }

    it 'coerces to a date' do
      expect([
        type['2015-11-26'],
        type['H27.11.26'],
        type['Thu, 26 Nov 2015 00:00:00 GMT']
      ]).to all(eql(Date.new(2015, 11, 26)))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date']).to eql('not-a-date')
      expect(type['12345678912/04/2017']).to eql ('12345678912/04/2017')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.date_time' do
    subject(:type) { Dry::Types['params.date_time'] }

    it 'coerces to a date time' do
      expect(type['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date-time']).to eql('not-a-date-time')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.time' do
    subject(:type) { Dry::Types['params.time'] }

    it 'coerces to a time' do
      expect(type['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-time']).to eql('not-a-time')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.bool' do
    subject(:type) { Dry::Types['params.bool'] }

    it 'coerces to true' do
      (Dry::Types::Coercions::Params::TRUE_VALUES + [1]).each do |value|
        expect(type[value]).to be(true)
      end
    end

    it 'coerces to false' do
      (Dry::Types::Coercions::Params::FALSE_VALUES + [0]).each do |value|
        expect(type[value]).to be(false)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.true' do
    subject(:type) { Dry::Types['params.true'] }

    it 'coerces to true' do
      %w[1 on  t true  y yes].each do |value|
        expect(type[value]).to be(true)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.false' do
    subject(:type) { Dry::Types['params.false'] }

    it 'coerces to false' do
      %w[0 off f false n no].each do |value|
        expect(type[value]).to be(false)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.integer' do
    subject(:type) { Dry::Types['params.integer'] }

    it 'coerces to an integer' do
      expect(type['312']).to be(312)
      expect(type['0']).to eql(0)
    end

    it 'coerces string with leading zero to an integer using 10 as a default base' do
      expect(type['010']).to be(10)
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
      expect(type['23asd']).to eql('23asd')
      expect(type[{}]).to eql({})
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.float' do
    subject(:type) { Dry::Types['params.float'] }

    it 'coerces to a float' do
      expect(type['3.12']).to eql(3.12)
    end

    it 'coerces zero values' do
      expect(type['0.0']).to eql(0.0)
      expect(type['0']).to eql(0.0)
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
      expect(type['23asd']).to eql('23asd')
      expect(type[{}]).to eql({})
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.decimal' do
    subject(:type) { Dry::Types['params.decimal'] }

    it 'coerces to a decimal' do
      expect(type['3.12']).to eql(BigDecimal('3.12'))
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
      expect(type['23asd']).to eql('23asd')
      expect(type[{}]).to eql({})
    end

    it 'does not lose precision of the original value' do
      expect(type['0.66666666666666666667']).to eql(BigDecimal('0.66666666666666666667'))
    end

    it 'coerces Float to BigDecimal without complaining about precision' do
      expect(type[3.12]).to eql(BigDecimal('3.12'))
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.array' do
    subject(:type) { Dry::Types['params.array'].of(Dry::Types['params.integer']) }

    it 'returns coerced array' do
      arr = %w(1 2 3)
      expect(type[arr]).to eql([1, 2, 3])
    end

    it 'coerces an empty string into an empty array' do
      input = ''
      expect(type[input]).to eql([])
    end

    it 'returns original value when it is not an array' do
      foo = 'foo'
      expect(type[foo]).to be(foo)
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end

  describe 'params.hash' do
    subject(:type) { Dry::Types['params.hash'].schema(age: Dry::Types['params.integer']) }

    it 'returns coerced hash' do
      hash = { age: '21' }
      expect(type[hash]).to eql(age: 21)
    end

    it 'coerces an empty string into an empty hash' do
      input = ''
      expect(type[input]).to eql({})
    end

    it 'returns original value when it is not an hash' do
      foo = 'foo'
      expect(type[foo]).to be(foo)
    end

    it 'returns original value when it is not a string' do
      object = Object.new
      expect(type[object]).to eql(object)
    end
  end
end
