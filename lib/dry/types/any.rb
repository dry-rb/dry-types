module Dry
  module Types
    Any = Class.new(Definition) do
      def initialize
        super(::Object)
      end

      # @return [String]
      def name
        'Any'
      end

      # @param [Object] any input is valid
      # @return [true]
      def valid?(_)
        true
      end
    end.new
  end
end
