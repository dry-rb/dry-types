module Dry
  module Types
    module Options
      # @return [Hash]
      attr_reader :options

      # @see Definition#initialize
      def initialize(*args, **options)
        @__args__ = args
        @options = options
        @meta = options.fetch(:meta, {})
      end

      # @param [Hash] new_options
      # @return [Type]
      def with(new_options)
        self.class.new(*@__args__, options.merge(new_options))
      end

      # @overload meta
      #   @return [Hash] metadata associated with type
      #
      # @overload meta(data)
      #   @param [Hash] new metadata to merge into existing metadata
      #   @return [Type] new type with added metadata
      def meta(data = nil)
        data ? with(meta: @meta.merge(data)) : @meta
      end
    end
  end
end
