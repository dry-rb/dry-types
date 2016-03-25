RSpec.describe Dry::Types::Definition do
  subject(:type) { Dry::Types::Definition.new(String) }

  it_behaves_like 'Dry::Types::Definition#meta'
end
