require 'dry/types/decorator'

module Dry
  module Types
    class Enum
      include Type
      include Dry::Equalizer(:type, :options, :mapping)
      include Decorator

      # @return [Array]
      attr_reader :values

      # @return [Hash]
      attr_reader :mapping

      # @return [Hash]
      attr_reader :inverted_mapping

      # @param [Type] type
      # @param [Hash] options
      # @option options [Array] :values
      def initialize(type, options)
        super
        @mapping = options.fetch(:mapping).freeze
        @values = @mapping.keys.freeze
        @inverted_mapping = @mapping.invert.freeze
        freeze
      end

      # @param [Object] input
      # @return [Object]
      def call(input = Undefined)
        type[map_value(input)]
      end
      alias_method :[], :call

      # @param [Object] input
      # @yieldparam [Failure] failure
      # @yieldreturn [Result]
      # @return [Logic::Result]
      # @return [Object] if coercion fails and a block is given
      def try(input)
        super(map_value(input))
      end

      def default(*)
        raise '.enum(*values).default(value) is not supported. Call '\
              '.default(value).enum(*values) instead'
      end

      # Check whether a value is in the enum
      alias_method :include?, :valid?

      # @api public
      #
      # @see Definition#to_ast
      def to_ast(meta: true)
        [:enum, [type.to_ast(meta: meta),
                 mapping,
                 meta ? self.meta : EMPTY_HASH]]
      end

      private

      # Maps a value
      #
      # @params [Object]
      # @return [Object]
      # @api private
      def map_value(input)
        if input.equal?(Undefined)
          type.call
        elsif mapping.key?(input)
          input
        else
          inverted_mapping.fetch(input, input)
        end
      end
    end
  end
end
