
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
          @cache = ::Concurrent::Map.new

          def self.call_class(method, public, safe)
            @cache.fetch_or_store([method, public, safe]) do
              if public
                interface = PublicCall.call_interface(method)

                ::Class.new(PublicCall) do
                  if safe
                    include interface
                  else
                    include SafeCall, interface
                  end
                end
              elsif safe
                PrivateCall
              else
                PrivateSafeCall
              end
            end
          end

          class PublicCall < MethodCall
            @interfaces = ::Concurrent::Map.new

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
          end

          class PrivateCall < MethodCall
            def call(input = Undefined, &block)
              @target.send(@name, input, &block)
            end
          end

          PrivateSafeCall = Class.new(PrivateCall) { include SafeCall }

          def self.[](fn, safe)
            public = fn.receiver.respond_to?(fn.name)
            MethodCall.call_class(fn.name, public, safe).new(fn)
          end

          attr_reader :target, :name

          def initialize(fn)
            super
            @target = fn.receiver
            @name = fn.name
          end

          def to_ast
            [:method, target, name]
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
          *, (last_arg,) =
            if fn.respond_to?(:parameters)
              fn.parameters
            else
              fn.method(:call).parameters
            end

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
          if fn.is_a?(::Proc)
            [:id, Dry::Types::FnContainer.register(fn)]
          else
            [:callable, fn]
          end
        end

        def wrapped?
          false
        end
      end
    end
  end
end
