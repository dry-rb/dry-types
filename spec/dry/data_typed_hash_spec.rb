RSpec.describe Dry::Data::TypedHash do
  describe '.new' do
    it 'builds hash using provided schema' do
      phone = Struct.new(:prefix, :number) do
        def self.name
          'Phone'
        end
      end

      Dry::Data.register(
        :phone,
        Dry::Data::Type.new(-> args { phone.new(*args) }, phone)
      )

      hash = Dry::Data::TypedHash.new(
        name: :string,
        age: :int,
        active: :bool,
        phone: :phone
      )

      user_hash = hash[
        name: :Jane, age: '21', active: true, phone: ['+48', '123-456-789']
      ]

      expect(user_hash).to eql(
        name: 'Jane', age: 21, active: true, phone: phone.new('+48', '123-456-789')
      )

      expect { hash[name: 'Jane', age: 21, active: 'true', phone: nil] }
        .to raise_error(TypeError, /"true" has invalid type/)
    end
  end
end
