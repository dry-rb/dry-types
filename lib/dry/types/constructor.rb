require 'dry/types/decorator'

module Dry
  module Types
    class Constructor
      include Dry::Equalizer(:type)

      include Decorator
      include Builder

      attr_reader :fn

      def initialize(type, fn)
        super
        @fn = fn
      end

      def call(input)
        fn[input]
      end
      alias_method :[], :call

      def constructor(other, options = {})
        super(-> input { other[fn[input]] }, options)
      end
    end
  end
end
