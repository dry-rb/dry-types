require 'dry/equalizer'

module Dry
  module Types
    class Result
      include Dry::Equalizer(:input)

      # @return [Object]
      attr_reader :input

      # @param [Object] input
      def initialize(input)
        @input = input
      end

      class Success < Result
        # @return [true]
        def success?
          true
        end

        # @return [false]
        def failure?
          false
        end
      end

      class Failure < Result
        include Dry::Equalizer(:input, :error)

        # @return [#to_s]
        attr_reader :error

        # @param [Object] input
        # @param [#to_s] error
        def initialize(input, error)
          super(input)
          @error = error
        end

        # @return [String]
        def to_s
          error.to_s
        end

        # @return [false]
        def success?
          false
        end

        # @return [true]
        def failure?
          true
        end
      end
    end
  end
end
