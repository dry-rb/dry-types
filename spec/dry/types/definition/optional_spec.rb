RSpec.describe Dry::Types::Definition, '#optional' do
  subject(:type) { Dry::Types['string'].optional }

  it 'returns None when value is nil' do
    expect(type[nil].value).to be(nil)
  end

  it 'returns Some when value exists' do
    expect(type['hello'].value).to eql('hello')
  end

  it 'aliases #[] as #call' do
    expect(type.call('hello').value).to eql('hello')
  end
end
