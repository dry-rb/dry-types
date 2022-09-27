# frozen_string_literal: true

module Dry
  module Types
    class Range < Nominal
      # Member ranges define their member type that is applied to begin and end
      #
      # @api public
      class Member < Range
        # @return [Type]
        attr_reader :member

        # @param [Class] primitive
        # @param [Hash] options
        #
        # @option options [Type] :member
        #
        # @api private
        def initialize(primitive, **options)
          @member = options.fetch(:member)
          super
        end

        # @param [Object] input
        #
        # @return [Range]
        #
        # @api private
        def call_unsafe(input)
          if primitive?(input)
            coerced_begin = member.call_unsafe(input.begin)
            coerced_end = member.call_unsafe(input.end)

            coerced_begin = nil if Undefined.equal?(coerced_begin)
            coerced_end = nil if Undefined.equal?(coerced_end)

            coerced_begin..coerced_end
          else
            super
          end
        end

        # @param [Object] input
        # @return [Range]
        #
        # @api private
        def call_safe(input)
          if primitive?(input)
            failed = false

            coerced_begin = member.call_safe(input.begin) { |out = input.begin|
              failed = true
              out
            }

            coerced_end = member.call_safe(input.end) { |out = input.end|
              failed = true
              out
            }

            coerced_begin = nil if Undefined.equal?(coerced_begin)
            coerced_end = nil if Undefined.equal?(coerced_end)

            output = coerced_begin..coerced_end

            failed ? yield(output) : output
          else
            yield
          end
        end

        # @param [Range, Object] input
        # @param [#call,nil] block
        #
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        #
        # @return [Result,Logic::Result]
        #
        # @api public
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/PerceivedComplexity
        def try(input, &block)
          if primitive?(input)
            result_begin = member.try(input.begin)
            result_end = member.try(input.end)

            output_begin = Undefined.equal?(result_begin.input) ? nil : result_begin.input
            output_end = Undefined.equal?(result_end.input) ? nil : result_end.input
            output = output_begin..output_end

            if result_begin.success? && result_end.success?
              success(output)
            else
              error = result_begin.failure? && result_begin.error ||
                      result_end.failure? && result_end.error
              failure = failure(output, error)
              block ? yield(failure) : failure
            end
          else
            failure = failure(input, CoercionError.new("#{input} is not a range"))
            block ? yield(failure) : failure
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/PerceivedComplexity

        # Build a lax type
        #
        # @return [Lax]
        #
        # @api public
        def lax
          Lax.new(Member.new(primitive, **options, member: member.lax, meta: meta))
        end

        # @see Nominal#to_ast
        #
        # @api public
        def to_ast(meta: true)
          if member.respond_to?(:to_ast)
            [:range, [member.to_ast(meta: meta), meta ? self.meta : EMPTY_HASH]]
          else
            [:range, [member, meta ? self.meta : EMPTY_HASH]]
          end
        end

        # @api private
        def constructor_type
          ::Dry::Types::Range::Constructor
        end
      end
    end
  end
end
