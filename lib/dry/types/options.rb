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
      # @return [Definition]
      def with(new_options)
        self.class.new(*@__args__, options.merge(new_options))
      end

      # @param [Hash] data
      # @return [Hash, Definition]
      def meta(data = nil)
        data ? with(meta: @meta.merge(data)) : @meta
      end
    end
  end
end
