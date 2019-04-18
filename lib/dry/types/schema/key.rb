# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Types
    class Schema < Hash
      # Proxy type for schema keys. Contains only key name and
      # whether it's required or not. All other calls deletaged
      # to the wrapped type.
      #
      # @see Dry::Types::Schema
      class Key
        include Type
        include Dry::Equalizer(:name, :type, :options, inspect: false)
        include Decorator
        include Builder
        include Printable

        # @return [Symbol]
        attr_reader :name

        # @api private
        def initialize(type, name, required: Undefined, **options)
          required = Undefined.default(required) do
            type.meta.fetch(:required) { !type.meta.fetch(:omittable, false) }
          end

          super(type, name, required: required, **options)
          @name = name
        end

        def call_safe(input, &block)
          type.call_safe(input, &block)
        end

        def call_unsafe(input)
          type.call_unsafe(input)
        end

        # @see Dry::Types::Nominal#try
        def try(input, &block)
          type.try(input, &block)
        end

        # Whether the key is required in schema input
        #
        # @return [Boolean]
        def required?
          options.fetch(:required)
        end

        # Control whether the key is required
        #
        # @overload required
        #   @return [Boolean]
        #
        # @overload required(required)
        #   Change key's "requireness"
        #
        #   @param [Boolean] required New value
        #   @return [Dry::Types::Schema::Key]
        def required(required = Undefined)
          if Undefined.equal?(required)
            options.fetch(:required)
          else
            with(required: required)
          end
        end

        # Make key not required
        #
        # @return [Dry::Types::Schema::Key]
        def omittable
          required(false)
        end

        # @see Dry::Types::Lax
        # @return [Dry::Types::Schema::Key]
        def lax
          super.required(false)
        end

        # Dump to internal AST representation
        #
        # @return [Array]
        def to_ast(meta: true)
          [
            :key,
            [
              name,
              required,
              type.to_ast(meta: meta)
            ]
          ]
        end

        private

        def decorate?(response)
          response.is_a?(Type)
        end
      end
    end
  end
end
