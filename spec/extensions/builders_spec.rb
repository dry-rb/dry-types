# frozen_string_literal: true

RSpec.describe Dry::Types::Builder do
  before(:all) { Dry::Types.load_extensions(:builders) }

  let(:base) { Dry::Types["string"].constrained(min_size: 4) }

  describe "#or_nil" do
    let(:type) { base.or_nil }

    it "returns nil on invalid input" do
      expect(type.("123")).to be_nil
      expect(type.("long")).to eql("long")
    end

    specify do
      expect(type).to be_optional
    end
  end
end
