# frozen_string_literal: true

require 'dry/types/decorator'

module Dry
  module Types
    # Lax types rescue from type-related errors when constructors fail and return nil
    #
    # @api public
    class OrNil
      include Type
      include Decorator
      include Builder
      include Printable
      include Dry::Equalizer(:type, inspect: false, immutable: true)

      undef :options, :constructor, :<<, :>>, :prepend, :append

      # @param [Object] input
      #
      # @return [Object]
      #
      # @api public
      def call(input)
        type.call_safe(input) { nil }
      end
      alias_method :[], :call
      alias_method :call_safe, :call
      alias_method :call_unsafe, :call

      # @param [Object] input
      # @param [#call,nil] block
      #
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      #
      # @return [Result,Logic::Result]
      #
      # @api public
      def try(input, &block)
        type.try(input, &block)
      end

      # @see Nominal#to_ast
      #
      # @api public
      def to_ast(meta: true)
        [:or_nil, type.to_ast(meta: meta)]
      end

      # @return [OrNix]
      #
      # @api public
      def or_nil
        self
      end

      private

      # @param [Object, Dry::Types::Constructor] response
      #
      # @return [Boolean]
      #
      # @api private
      def decorate?(response)
        super || response.is_a?(type.constructor_type)
      end
    end
  end
end
