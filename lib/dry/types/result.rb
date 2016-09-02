require 'dry/equalizer'

module Dry
  module Types
    class Result
      include Dry::Equalizer(:input)

      attr_reader :input

      def initialize(input)
        @input = input
      end

      class Success < Result
        def success?
          true
        end

        def failure?
          false
        end
      end

      class Failure < Result
        include Dry::Equalizer(:input, :error)

        attr_reader :error

        def initialize(input, error)
          super(input)
          @error = error
        end

        def to_s
          error.to_s
        end

        def success?
          false
        end

        def failure?
          true
        end
      end
    end
  end
end
