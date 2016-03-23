module Dry
  module Types
    class Definition
      class Array < Definition
        def self.new(primitive, options = {})
          super(primitive, { member_type: -> v { v } }.merge(options))
        end

        def member(type)
          member_type =
            case type
            when String, Class then Types[type]
            else type
            end

          with(member_type: member_type)
        end

        def member_type
          options[:member_type]
        end

        def call(input, meth = :call)
          input.map { |el| member_type.__send__(meth, el) }
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
