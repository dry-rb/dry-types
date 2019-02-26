require 'dry/types/constructor'

module Dry
  module Types
    class Hash < Definition
      class Constructor < ::Dry::Types::Constructor
        # @api private
        def constructor_type
          ::Dry::Types::Hash::Constructor
        end

        private

        def composable?(value)
          super && !value.is_a?(Key)
        end
      end
    end
  end
end
