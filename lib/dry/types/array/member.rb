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

        def try(input, &block)
          result = call(input, :try)

          if result.all?(&:success?)
            success(result.map(&:input))
          else
            failure = failure(input, result.select(&:failure?))
            block ? yield(failure) : failure
          end
        end
      end
    end
  end
end
