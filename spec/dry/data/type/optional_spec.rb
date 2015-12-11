RSpec.describe Dry::Data::Type, '#optional' do
  subject(:type) { Dry::Data['string'].optional }

  it 'returns None when value is nil' do
    expect(type[nil].value).to be(nil)
  end

  it 'returns Some when value exists' do
    expect(type['hello'].value).to eql('hello')
  end
end
