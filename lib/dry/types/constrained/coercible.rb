# frozen_string_literal: true

module Dry
  module Types
    class Constrained
      class Coercible < Constrained
        # @api private
        # @return [Object]
        def call_unsafe(input)
          coerced = type.call_unsafe(input)
          result = rule.(coerced)

          if result.success?
            coerced
          else
            raise ConstraintError.new(result, input)
          end
        end

        # @api private
        # @return [Object]
        def call_safe(input)
          coerced = type.call_safe(input) { return yield }

          if rule[coerced]
            coerced
          else
            yield(coerced)
          end
        end

        # @see Dry::Types::Constrained#try
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
