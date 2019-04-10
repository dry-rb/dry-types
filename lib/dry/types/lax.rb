
require 'dry/core/deprecations'
require 'dry/types/decorator'

module Dry
  module Types
    class Lax
      include Type
      include Decorator
      include Builder
      include Printable
      include Dry::Equalizer(:type, inspect: false)

      private :options, :meta, :constructor

      # @param [Object] input
      # @return [Object]
      def call(input)
        type.(input) { |output = input| output }
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call,nil] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result,Logic::Result]
      def try(input, &block)
        type.try(input, &block)
      rescue CoercionError => error
        result = failure(input, error.message)
        block ? yield(result) : result
      end

      # @api public
      #
      # @see Nominal#to_ast
      def to_ast(meta: true)
        [:lax, [type.to_ast(meta: meta), EMPTY_HASH]]
      end

      # @api public
      # @return [Lax]
      def lax
        self
      end

      private

      # @param [Object, Dry::Types::Constructor] response
      # @return [Boolean]
      def decorate?(response)
        super || response.is_a?(constructor_type)
      end
    end

    extend ::Dry::Core::Deprecations[:'dry-types']
    Safe = Lax
    deprecate_constant(:Safe)
  end
end
