module Dry
  module Types
    class Constrained
      class Coercible < Constrained
        def try(input, &block)
          result = type.try(input)

          if result.success?
            validation = rule.(result.input)

            if validation.success?
              result
            else
              block ? yield(validation) : validation
            end
          else
            block ? yield(result) : result
          end
        end
      end
    end
  end
end
