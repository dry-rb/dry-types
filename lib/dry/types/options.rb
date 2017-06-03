module Dry
  module Types
    module Options
      # @return [Hash]
      attr_reader :options

      # @see Definition#initialize
      def initialize(*args, meta: EMPTY_HASH, **options)
        @__args__ = args
        @options = options
        @meta = meta
      end

      # @param [Hash] new_options
      # @return [Type]
      def with(new_options)
        self.class.new(*@__args__, **options, meta: @meta, **new_options)
      end

      # @overload meta
      #   @return [Hash] metadata associated with type
      #
      # @overload meta(data)
      #   @param [Hash] new metadata to merge into existing metadata
      #   @return [Type] new type with added metadata
      def meta(data = nil)
        if !data
          @meta
        elsif data.empty?
          self
        else
          with(meta: @meta.merge(data))
        end
      end

      # Resets meta
      # @return [Dry::Types::Type]
      def pristine
        with(meta: EMPTY_HASH)
      end
    end
  end
end
