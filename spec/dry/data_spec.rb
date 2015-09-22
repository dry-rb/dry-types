require 'spec_helper'

RSpec.describe Dry::Data do
  describe '.register' do
    it 'registers a new type constructor' do
      class CustomArray
        def self.new(input)
          Array(input)
        end
      end

      Dry::Data.register(CustomArray, CustomArray.method(:new))

      type = Dry::Data.new { |t| t['CustomArray'] }

      expect(type['foo']).to eql(['foo'])
    end
  end
end
