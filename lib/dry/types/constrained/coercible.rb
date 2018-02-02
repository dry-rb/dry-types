module Dry
  module Types
    class Constrained
      class Coercible < Constrained
        # @param [Object] input
        # @param [#call,nil] block
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        # @return [Result,nil]
        def try(input, &block)
          result = type.try(input)

          if result.success?
            validation = rule.(result.input)

            if validation.success?
              result
            else
              failure = failure(result.input, validation)
              block ? yield(failure) : failure
            end
          else
            block ? yield(result) : result
          end
        end
      end
    end
  end
end
