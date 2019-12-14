# frozen_string_literal: true

RSpec.describe 'dry types errors' do
  describe Dry::Types::CoercionError do
    it 'requires a string message' do
      expect {
        described_class.new(:invalid)
      }.to raise_error(ArgumentError, /message must be a string/)
    end
  end
end
