module Dry
  module Types
    module Result
      class Success < Struct.new(:input)
        def success?
          true
        end

        def failure?
          false
        end
      end

      class Failure < Struct.new(:input, :error)
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
