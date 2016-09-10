module Dry
  module Types
    class Array < Definition
      class Member < Array
        attr_reader :member

        def initialize(primitive, options = {})
          @member = options.fetch(:member)
          super
        end

        def call(input, meth = :call)
          input.map { |el| member.__send__(meth, el) }
        end
        alias_method :[], :call

        def valid?(type)
          super && type.all? { |el| member.valid?(el) }
        end

        def try(input, &block)
          if input.is_a?(::Array)
            result = call(input, :try)
            output = result.map(&:input)

            if result.all?(&:success?)
              success(output)
            else
              failure = failure(output, result.select(&:failure?))
              block ? yield(failure) : failure
            end
          else
            failure = failure(input, "#{input} is not an array")
            block ? yield(failure) : failure
          end
        end
      end
    end
  end
end
