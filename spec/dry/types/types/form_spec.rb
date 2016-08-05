RSpec.describe Dry::Types::Definition do
  describe 'form.nil' do
    subject(:type) { Dry::Types['form.nil'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it is not an empty string' do
      expect(type[['foo']]).to eql(['foo'])
    end
  end

  describe 'form.nil | form.int' do
    subject(:type) { Dry::Types['form.nil'] | Dry::Types['form.int'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'coerces string to an integer' do
      expect(type['23']).to be(23)
    end
  end

  describe 'form.date' do
    subject(:type) { Dry::Types['form.date'] }

    it 'coerces to a date' do
      expect([
        type['2015-11-26'],
        type['H27.11.26'],
        type['Thu, 26 Nov 2015 00:00:00 GMT']
      ]).to all(eql(Date.new(2015, 11, 26)))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date']).to eql('not-a-date')
    end
  end

  describe 'form.date_time' do
    subject(:type) { Dry::Types['form.date_time'] }

    it 'coerces to a date time' do
      expect(type['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date-time']).to eql('not-a-date-time')
    end
  end

  describe 'form.time' do
    subject(:type) { Dry::Types['form.time'] }

    it 'coerces to a time' do
      expect(type['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-time']).to eql('not-a-time')
    end
  end

  describe 'form.bool' do
    subject(:type) { Dry::Types['form.bool'] }

    it 'coerces to true' do
      %w[1 on T t true  y yes] + [1].each do |value|
        expect(type[value]).to be(true)
      end
    end

    it 'coerces to false' do
      %w[0 off F f false n no] + [0].each do |value|
        expect(type[value]).to be(false)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end
  end

  describe 'form.true' do
    subject(:type) { Dry::Types['form.true'] }

    it 'coerces to true' do
      %w[1 on  t true  y yes].each do |value|
        expect(type[value]).to be(true)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end
  end

  describe 'form.false' do
    subject(:type) { Dry::Types['form.false'] }

    it 'coerces to false' do
      %w[0 off f false n no].each do |value|
        expect(type[value]).to be(false)
      end
    end

    it 'returns original value when it is not supported' do
      expect(type['huh?']).to eql('huh?')
    end
  end

  describe 'form.int' do
    subject(:type) { Dry::Types['form.int'] }

    it 'coerces to a integer' do
      expect(type['312']).to be(312)
      expect(type['0']).to eql(0)
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
      expect(type['23asd']).to eql('23asd')
      expect(type[{}]).to eql({})
    end
  end

  describe 'form.float' do
    subject(:type) { Dry::Types['form.float'] }

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
  end

  describe 'form.decimal' do
    subject(:type) { Dry::Types['form.decimal'] }

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
  end

  describe 'form.array' do
    subject(:type) { Dry::Types['form.array'].member(Dry::Types['form.int']) }

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
  end

  describe 'form.hash' do
    subject(:type) { Dry::Types['form.hash'].weak(age: Dry::Types['form.int']) }

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
  end
end
