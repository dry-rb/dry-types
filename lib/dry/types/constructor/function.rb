module Dry
  module Types
    class Constructor < Nominal
      class Function
        class Safe < Function
          def call(input, &fallback)
            super
          rescue NoMethodError, TypeError, ArgumentError => error
            CoercionError.handle(error, &fallback)
          end

          def wrapped?
            true
          end
        end

        def self.[](fn, options = EMPTY_HASH)
          raise ArgumentError, 'Missing constructor block' if fn.nil?

          if fn.is_a?(Function)
            fn
          else
            parameters = fn.respond_to?(:parameters) ? fn.parameters : fn.method(:call).parameters
            *, (last_arg,) = parameters

            if last_arg.equal?(:block)
              new(fn)
            else
              Safe.new(fn)
            end
          end
        end

        include Dry::Equalizer(:fn)

        attr_reader :fn

        def initialize(fn)
          @fn = fn
        end

        def call(input, &block)
          @fn.(input, &block)
        end
        alias_method :[], :call

        def to_ast
          Dry::Types::FnContainer.register(fn)
        end

        def wrapped?
          false
        end
      end
    end
  end
end
