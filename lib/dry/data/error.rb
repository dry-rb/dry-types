module Dry
  module Data
    Error = Class.new(StandardError)
    class TypeError < Error
      def initialize(input)
        super("#{input.inspect} has an invalid type")
      end
    end
  end
end
