require 'ice_nine'

require 'dry/types/struct'

module Dry
  module Types
    class Value < Struct
      def self.new(*)
        IceNine.deep_freeze(super)
      end
    end
  end
end
