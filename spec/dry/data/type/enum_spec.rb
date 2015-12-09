RSpec.describe Dry::Data::Type::Enum do
  subject(:type) { Dry::Data['string'].enum(*values) }

  let(:values) { %w(draft published archived) }
  let(:string) { Dry::Data['strict.string'] }

  it_behaves_like Dry::Data::Type

  it 'allows defining an enum from a specific type' do
    expect(type['draft']).to eql('draft')
    expect(type['published']).to eql('published')
    expect(type['archived']).to eql('archived')

    expect(type[0]).to eql('draft')
    expect(type[1]).to eql('published')
    expect(type[2]).to eql('archived')

    expect(type.values).to eql(values)

    expect { type['oops'] }.to raise_error(Dry::Data::ConstraintError, /oops/)

    expect(type.values).to be_frozen
  end
end
