require 'spec_helper'

RSpec.describe Dry::Data do
  describe '.register' do
    it 'registers a new type constructor' do
      constructor = -> input { Array[input] }

      Dry::Data.register('CustomArray', constructor)

      type = Dry::Data.new { |t| t['CustomArray'] }

      expect(type['foo']).to eql(['foo'])
    end
  end
end
