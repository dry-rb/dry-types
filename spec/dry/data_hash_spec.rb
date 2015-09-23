RSpec.describe Dry::Data::TypedHash do
  describe '.new' do
    it 'builds hash using provided schema' do
      hash = Dry::Data::TypedHash.new(name: 'String', age: 'Integer', active: 'Bool')

      expect(hash[name: :Jane, age: '21', active: true]).to eql(
        name: 'Jane', age: 21, active: true
      )

      expect { hash[name: 'Jane', age: 21, active: 'true'] }
        .to raise_error(TypeError, /"true" has invalid type/)
    end
  end
end
