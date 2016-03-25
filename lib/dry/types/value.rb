require 'dry/types/struct'

module Dry
  module Types
    class Value < Struct
      def self.new(*, &_block)
        super.freeze
      end
    end
  end
end
