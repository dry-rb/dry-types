RSpec.describe Dry::Data::Type, '#safe' do
  subject(:type) { Dry::Data['string'].constrained(min_size: 5).safe }

  it 'uses constructor when primitive matches' do
    expect(type['passing']).to eql('passing')
    expect { type['pass'] }.to raise_error(Dry::Data::ConstraintError, /pass/)
  end

  it 'skips constructor when primitive does not match' do
    expect(type[:passing]).to be(:passing)
  end

  it 'aliases #[] as #call' do
    expect(type.call(:passing)).to be(:passing)
  end
end
