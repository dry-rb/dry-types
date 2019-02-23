require 'dry/equalizer'

module Dry
  module Types
    class Hash < Definition
      class Key
        include Type
        include ::Dry::Equalizer(:name, :type, :options)
        include Decorator
        include Builder

        attr_reader :name

        def initialize(type, name, required: Undefined, **options)
          required = Undefined.default(required) do
            type.meta.fetch(:required) { !type.meta.fetch(:omittable, false) }
          end

          super(type, name, required: required, **options)
          @name = name
        end

        def call(input, &block)
          type.(input, &block)
        end

        def try(input, &block)
          type.try(input, &block)
        end

        def required?
          options.fetch(:required)
        end

        def required(required = Undefined)
          if Undefined.equal?(required)
            options.fetch(:required)
          else
            with(required: required)
          end
        end

        def omittable
          required(false)
        end

        def default(input = Undefined, &block)
          new(type.default(input, &block))
        end

        def new(type)
          self.class.new(type, name, options)
        end

        def safe
          new(type.safe)
        end

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
