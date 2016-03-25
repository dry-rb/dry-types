RSpec.describe Dry::Types::Definition do
  subject(:type) { Dry::Types::Definition.new(String) }

  it_behaves_like 'Dry::Types::Definition#meta'

  it 'is frozen' do
    expect(type).to be_frozen
  end
end
