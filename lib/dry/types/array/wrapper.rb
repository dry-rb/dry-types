# frozen_string_literal: true

require 'dry/types/wrapper'

module Dry
  module Types
    # @api public
    class Array < Nominal
      # @api private
      class Wrapper < ::Dry::Types::Wrapper
        # @api private
        def wrapper_type
          ::Dry::Types::Array::Wrap
        end

        # @return [Lax]
        #
        # @api public
        def lax
          Lax.new(type.lax.wrap(fn, meta: meta))
        end

        # @see Dry::Types::Array#of
        #
        # @api public
        def of(member)
          type.of(member).wrap(fn, meta: meta)
        end
      end
    end
  end
end
