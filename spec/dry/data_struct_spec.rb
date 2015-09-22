RSpec.describe Dry::Data::Struct do
  describe '.attribute' do
    it 'defines an attribute for the constructor' do
      class User
        include Dry::Data::Struct

        attributes String => :name, Integer => :age
      end

      user_type = Dry::Data.new { |t| t['User'] }

      user = user_type[name: :Jane, age: '21']

      expect(user.name).to eql('Jane')
      expect(user.age).to be(21)
    end
  end
end
