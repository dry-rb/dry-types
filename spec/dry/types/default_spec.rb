RSpec.describe Dry::Types::Type, '#default' do
  subject(:type) { Dry::Types['string'].default('foo') }

  it 'returns default value when nil is passed' do
    expect(type[nil]).to eql('foo')
  end

  it 'aliases #[] as #call' do
    expect(type.call(nil)).to eql('foo')
  end

  it 'returns original value when it is not nil' do
    expect(type['bar']).to eql('bar')
  end
end
