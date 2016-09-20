RSpec.describe Dry::Types::Hash, ':symbolized constructor' do
  subject(:hash) do
    Dry::Types['hash'].symbolized(
      name: 'string',
      email: email,
      age: 'int',
      password: password
    )
  end

  let(:email) { Dry::Types['optional.strict.string'] }
  let(:password) { Dry::Types['strict.string'].default('changeme') }

  describe '#[]' do
    it 'changes string keys to symbols' do
      expect(hash['name' => 'Jane', 'email' => 'foo@bar.com', 'age' => 1]).to eql(
        name: 'Jane', email: 'foo@bar.com', age: 1, password: 'changeme'
      )
    end

    it 'sets default when value is nil' do
      expect(hash['name' => 'Jane', 'email' => 'foo@bar.com', 'age' => 1, 'password' => nil]).to eql(
        name: 'Jane', email: 'foo@bar.com', age: 1, password: 'changeme'
      )
    end

    it 'sets nil as a default value for optional' do
      result = hash['name' => 'Jane', 'age' => 1]

      expect(result[:email]).to be_nil
    end

    it 'passes through already symbolized hash' do
      result = hash[name: 'Jane', age: 1]

      expect(result).to eql(name: 'Jane', age: 1, password: 'changeme')
    end
  end
end
