require 'dry/types/decorator'

module Dry
  module Types
    class Safe
      include Type
      include Dry::Equalizer(:type, :options)
      include Decorator
      include Builder

      # @param [Object] input
      # @return [Object]
      def call(input)
        result = try(input)

        if result.respond_to?(:input)
          result.input
        else
          input
        end
      end
      alias_method :[], :call

      # @param [Object] input
      # @param [#call,nil] block
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Result,Logic::Result]
      def try(input, &block)
        type.try(input, &block)
      rescue TypeError, ArgumentError => e
        result = failure(input, e.message)
        block ? yield(result) : result
      end

      # @api public
      #
      # @see Definition#to_ast
      def to_ast(meta: true)
        [:safe, [type.to_ast, meta ? self.meta : EMPTY_HASH]]
      end

      # @api public
      # @return [Safe]
      def safe
        self
      end

      private

      # @param [Object, Dry::Types::Constructor] response
      # @return [Boolean]
      def decorate?(response)
        super || response.kind_of?(Constructor)
      end
    end
  end
end
