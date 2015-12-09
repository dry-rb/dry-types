RSpec.describe Dry::Data::Type, '#enum' do
  let(:string) { Dry::Data['strict.string'] }

  it 'allows defining an enum from a specific type' do
    values = %w(draft published archived)
    states = Dry::Data['string'].enum(*values)

    expect(states['draft']).to eql('draft')
    expect(states['published']).to eql('published')
    expect(states['archived']).to eql('archived')

    expect(states[0]).to eql('draft')
    expect(states[1]).to eql('published')
    expect(states[2]).to eql('archived')

    expect(states.values).to eql(values)

    expect { states['oops'] }.to raise_error(Dry::Data::ConstraintError, /oops/)

    expect(states.values).to be_frozen
  end
end
