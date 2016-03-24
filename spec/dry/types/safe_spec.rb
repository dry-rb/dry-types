RSpec.describe Dry::Types::Definition, '#safe' do
  subject(:type) { Dry::Types['coercible.string'].constrained(min_size: 5).safe }

  it 'rescues from type-errors and returns input' do
    expect(type['pass']).to eql('pass')
  end

  it 'skips constructor when primitive does not match' do
    expect(type[:passing]).to be(:passing)
  end

  it 'aliases #[] as #call' do
    expect(type.call(:passing)).to be(:passing)
  end
end
