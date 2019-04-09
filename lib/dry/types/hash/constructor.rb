require 'dry/types/constructor'

module Dry
  module Types
    class Hash < Nominal
      class Constructor < ::Dry::Types::Constructor
        # @api private
        def constructor_type
          ::Dry::Types::Hash::Constructor
        end

        def safe
          type.safe.constructor(fn, meta: meta)
        end

        private

        def composable?(value)
          super && !value.is_a?(Schema::Key)
        end
      end
    end
  end
end
