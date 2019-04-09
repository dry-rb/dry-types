module Dry
  module Types
    class Array < Nominal
      class Member < Array
        # @return [Type]
        attr_reader :member

        # @param [Class] primitive
        # @param [Hash] options
        # @option options [Type] :member
        def initialize(primitive, options = {})
          @member = options.fetch(:member)
          super
        end

        # @param [Object] input
        # @return [Array]
        def call(input, &block)
          if primitive?(input)
            input.each_with_object([]) do |el, output|
              coerced =
                if block_given?
                  member.(el) { return yield }
                else
                  member.(el)
                end

              output << coerced unless Undefined.equal?(coerced)
            end
          elsif block_given?
            yield
          else
            super
          end
        end
        alias_method :[], :call

        # @param [Array, #all?, Object] value
        # @return [Boolean]
        def valid?(value)
          super && value.all? { |el| member.valid?(el) }
        end

        # @param [Array, Object] input
        # @param [#call,nil] block
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        # @return [Result,Logic::Result]
        def try(input, &block)
          if primitive?(input)
            output = []

            result = input.map { |el| member.try(el) }
            result.each do |r|
              output << r.input unless Undefined.equal?(r.input)
            end

            if result.all?(&:success?)
              success(output)
            else
              error = result.find(&:failure?).error
              failure = failure(output, error)
              block ? yield(failure) : failure
            end
          else
            failure = failure(input, "#{input} is not an array")
            block ? yield(failure) : failure
          end
        end

        def safe
          Safe.new(Member.new(primitive, { **options, member: member.safe}))
        end

        # @api public
        #
        # @see Nominal#to_ast
        def to_ast(meta: true)
          if member.respond_to?(:to_ast)
            [:array, [member.to_ast(meta: meta), meta ? self.meta : EMPTY_HASH]]
          else
            [:array, [member, meta ? self.meta : EMPTY_HASH]]
          end
        end
      end
    end
  end
end
