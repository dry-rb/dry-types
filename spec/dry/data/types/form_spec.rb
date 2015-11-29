require 'dry/data/types/form'

RSpec.describe Dry::Data::Type do
  describe 'form.nil' do
    subject(:type) { Dry::Data['form.nil'] }

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it is not an empty string' do
      expect(type[['foo']]).to eql(['foo'])
    end
  end

  describe 'form.date' do
    subject(:type) { Dry::Data['form.date'] }

    it 'coerces to a date' do
      expect(type['2015-11-26']).to eql(Date.new(2015, 11, 26))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date']).to eql('not-a-date')
    end
  end

  describe 'form.date_time' do
    subject(:type) { Dry::Data['form.date_time'] }

    it 'coerces to a date time' do
      expect(type['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-date-time']).to eql('not-a-date-time')
    end
  end

  describe 'form.time' do
    subject(:type) { Dry::Data['form.time'] }

    it 'coerces to a time' do
      expect(type['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end

    it 'returns original value when it was unparsable' do
      expect(type['not-a-time']).to eql('not-a-time')
    end
  end

  describe 'form.bool' do
    subject(:type) { Dry::Data['form.bool'] }

    it 'coerces to true' do
      %w[1 on  t true  y yes].each do |value|
        expect(type[value]).to be(true)
      end
    end

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
    subject(:type) { Dry::Data['form.int'] }

    it 'coerces to a integer' do
      expect(type['312']).to be(312)
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
    end
  end

  describe 'form.float' do
    subject(:type) { Dry::Data['form.float'] }

    it 'coerces to a float' do
      expect(type['3.12']).to eql(3.12)
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
    end
  end

  describe 'form.decimal' do
    subject(:type) { Dry::Data['form.decimal'] }

    it 'coerces to a decimal' do
      expect(type['3.12']).to eql(BigDecimal('3.12'))
    end

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end

    it 'returns original value when it cannot be coerced' do
      expect(type['foo']).to eql('foo')
    end
  end
end
