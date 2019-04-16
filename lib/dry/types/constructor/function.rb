
# frozen_string_literal: true

require 'concurrent/map'

module Dry
  module Types
    class Constructor < Nominal
      class Function
        module SafeCall
          def call(input, &fallback)
            super
          rescue NoMethodError, TypeError, ArgumentError => error
            CoercionError.handle(error, &fallback)
          end

          def wrapped?
            true
          end
        end

        Safe = ::Class.new(Function) { include SafeCall }

        class MethodCall < Function
          @interfaces = ::Concurrent::Map.new
          @cache = ::Concurrent::Map.new

          def self.call_interface(method)
            @interfaces.fetch_or_store(method) do
              ::Module.new do
                module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
                  def call(input = Undefined, &block)
                    @target.#{method}(input, &block)
                  end
                RUBY
              end
            end
          end

          def self.call_class(method, safe)
            @cache.fetch_or_store([method, safe]) do
              interface = MethodCall.call_interface(method)

              ::Class.new(MethodCall) do
                if safe
                  include interface
                else
                  include SafeCall, interface
                end
              end
            end
          end

          def self.[](fn, safe)
            MethodCall.call_class(fn.name, safe).new(fn)
          end

          def initialize(fn)
            super
            @target = fn.receiver
            @method = fn.name
          end
        end

        def self.[](fn)
          raise ArgumentError, 'Missing constructor block' if fn.nil?

          if fn.is_a?(Function)
            fn
          elsif fn.is_a?(::Method)
            MethodCall[fn, yields_fallback?(fn)]
          elsif yields_fallback?(fn)
            new(fn)
          else
            Safe.new(fn)
          end
        end

        def self.yields_fallback?(fn)
          parameters = fn.respond_to?(:parameters) ? fn.parameters : fn.method(:call).parameters
          *, (last_arg,) = parameters
          last_arg.equal?(:block)
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
