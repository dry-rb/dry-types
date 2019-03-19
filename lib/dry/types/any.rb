module Dry
  module Types
    Any = Class.new(Nominal) do
      def self.name
        'Any'
      end

      def initialize(**options)
        super(::Object, options)
      end

      # @return [String]
      def name
        'Any'
      end

      # @param [Object] any input is valid
      # @return [true]
      def valid?(_)
        true
      end
      alias_method :===, :valid?

      # @param [Hash] new_options
      # @return [Type]
      def with(**new_options)
        self.class.new(**options, meta: @meta, **new_options)
      end

      # @return [Array]
      def to_ast(meta: true)
        [:any, meta ? self.meta : EMPTY_HASH]
      end
    end.new
  end
end
