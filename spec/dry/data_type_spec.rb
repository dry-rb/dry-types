RSpec.describe Dry::Data::Type do
  let(:string) { Dry::Data.new { |t| t['String'] } }
  let(:hash) { Dry::Data.new { |t| t['Hash'] } }

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
  end

  describe 'with Date' do
    let(:datetime) { Dry::Data.new { |t| t['Date'] } }

    it 'accepts a date object' do
      input = Date.new

      expect(datetime[input]).to be(input)
    end
  end

  describe 'with DateTime' do
    let(:datetime) { Dry::Data.new { |t| t['DateTime'] } }

    it 'accepts a date-time object' do
      input = DateTime.new

      expect(datetime[input]).to be(input)
    end
  end

  describe 'with Time' do
    let(:datetime) { Dry::Data.new { |t| t['Time'] } }

    it 'accepts a time object' do
      input = Time.new

      expect(datetime[input]).to be(input)
    end
  end
end
