# frozen_string_literal: true

module Dry
  module Types
    module Meta
      def initialize(*args, meta: EMPTY_HASH, **options)
        super(*args, **options)
        @meta = meta.freeze
      end

      # @param [Hash] new_options
      # @return [Type]
      def with(**options)
        super(meta: @meta, **options)
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
