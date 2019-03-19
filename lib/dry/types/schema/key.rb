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

        # @see Dry::Types::Nominal#call
        def call(input, &block)
          type.(input, &block)
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

        # Construct a default type. Default values are
        # evaluated/applied when key is absent in schema
        # input.
        #
        # @see Dry::Types::Default
        # @return [Dry::Types::Schema::Key]
        def default(input = Undefined, &block)
          new(type.default(input, &block))
        end

        # Replace the underlying type
        # @param [Dry::Types::Type] type
        # @return [Dry::Types::Schema::Key]
        def new(type)
          self.class.new(type, name, options)
        end

        # @see Dry::Types::Safe
        # @return [Dry::Types::Schema::Key]
        def safe
          new(type.safe)
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

        # Get/set type metadata. The Key type doesn't have
        # its out meta, it delegates these calls to the underlying
        # type.
        #
        # @overload meta
        #   @return [Hash] metadata associated with type
        #
        # @overload meta(data)
        #   @param [Hash] new metadata to merge into existing metadata
        #   @return [Type] new type with added metadata
        def meta(data = nil)
          if data.nil?
            type.meta
          else
            new(type.meta(data))
          end
        end
      end
    end
  end
end
