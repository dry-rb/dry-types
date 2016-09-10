module Dry
  module Types
    module Options
      attr_reader :options

      def initialize(*args, **options)
        @__args__ = args
        @options = options
        @meta = options.fetch(:meta, {})
      end

      def with(new_options)
        self.class.new(*@__args__, options.merge(new_options))
      end

      def meta(data = nil)
        data ? with(meta: @meta.merge(data)) : @meta
      end
    end
  end
end
