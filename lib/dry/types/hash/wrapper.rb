# frozen_string_literal: true

require 'dry/types/wrapper'

module Dry
  module Types
    # Hash type exposes additional APIs for working with schema hashes
    #
    # @api public
    class Hash < Nominal
      class Wrapper < ::Dry::Types::Wrapper
        # @api private
        def wrapper_type
          ::Dry::Types::Hash::Wrap
        end

        # @return [Lax]
        #
        # @api public
        def lax
          type.lax.wrap(fn, meta: meta)
        end

        # @see Dry::Types::Array#of
        #
        # @api public
        def schema(*args)
          type.schema(*args).wrap(fn, meta: meta)
        end
      end
    end
  end
end
