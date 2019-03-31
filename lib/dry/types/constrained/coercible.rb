module Dry
  module Types
    class Constrained
      class Coercible < Constrained
        def call(input, &block)
          coerced = type.(input) { return yield if block_given? }
          result = rule.(coerced)

          if result.success?
            coerced
          elsif block_given?
            yield(coerced)
          else
            raise ConstraintError.new(result, input)
          end
        end

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
              failure = failure(result.input, ConstraintError.new(validation, input))
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
