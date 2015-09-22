require 'spec_helper'

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
end
