# frozen_string_literal: true

module Dry
  module Types
    # @api public
    class Range < Nominal
      # @api private
      class Constructor < ::Dry::Types::Constructor
        # @api private
        def constructor_type
          ::Dry::Types::Range::Constructor
        end

        # @return [Lax]
        #
        # @api public
        def lax
          Lax.new(type.lax.constructor(fn, meta: meta))
        end

        # @see Dry::Types::Range#of
        #
        # @api public
        def of(member)
          type.of(member).constructor(fn, meta: meta)
        end
      end
    end
  end
end
