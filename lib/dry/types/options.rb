# frozen_string_literal: true

module Dry
  module Types
    module Options
      # @return [Hash]
      attr_reader :options

      # @see Nominal#initialize
      def initialize(*args, **options)
        @__args__ = args.freeze
        @options = options.freeze
      end

      # @param [Hash] new_options
      # @return [Type]
      def with(**new_options)
        self.class.new(*@__args__, **options, **new_options)
      end
    end
  end
end
