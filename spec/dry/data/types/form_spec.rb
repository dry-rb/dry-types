require 'dry/data/types/form'

RSpec.describe Dry::Data::Type do
  describe 'form.date' do
    subject(:date) { Dry::Data['form.date'] }

    it 'coerces to a date' do
      expect(date['2015-11-26']).to eql(Date.new(2015, 11, 26))
    end
  end

  describe 'form.date_time' do
    subject(:date) { Dry::Data['form.date_time'] }

    it 'coerces to a date time' do
      expect(date['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end
  end

  describe 'form.time' do
    subject(:date) { Dry::Data['form.time'] }

    it 'coerces to a time' do
      expect(date['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end
  end

  describe 'form.bool' do
    subject(:date) { Dry::Data['form.bool'] }

    it 'coerces to true' do
      %w[1 on  t true  y yes].each do |value|
        expect(date[value]).to be(true)
      end
    end

    it 'coerces to false' do
      %w[0 off f false n no].each do |value|
        expect(date[value]).to be(false)
      end
    end
  end

  describe 'form.int' do
    subject(:date) { Dry::Data['form.int'] }

    it 'coerces to a integer' do
      expect(date['312']).to be(312)
    end

    it 'coerces empty string to nil' do
      expect(date['']).to be(nil)
    end
  end

  describe 'form.float' do
    subject(:date) { Dry::Data['form.float'] }

    it 'coerces to a float' do
      expect(date['3.12']).to be(3.12)
    end

    it 'coerces empty string to nil' do
      expect(date['']).to be(nil)
    end
  end

  describe 'form.decimal' do
    subject(:date) { Dry::Data['form.decimal'] }

    it 'coerces to a decimal' do
      expect(date['3.12']).to eql(BigDecimal('3.12'))
    end

    it 'coerces empty string to nil' do
      expect(date['']).to be(nil)
    end
  end
end
