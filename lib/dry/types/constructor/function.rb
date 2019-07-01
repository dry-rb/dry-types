# frozen_string_literal: true

require 'concurrent/map'

module Dry
  module Types
    class Constructor < Nominal
      # Function is used internally by Constructor types
      #
      # @api private
      class Function
        # Wrapper for unsafe coercion functions
        #
        # @api private
        class Safe < Function
          def call(input, &block)
            @fn.(input, &block)
          rescue NoMethodError, TypeError, ArgumentError => e
            CoercionError.handle(e, &block)
          end
        end

        # Coercion via a method call on a known object
        #
        # @api private
        class MethodCall < Function
          @cache = ::Concurrent::Map.new

          # Choose or build the base class
          #
          # @return [Function]
          def self.call_class(method, public, safe)
            @cache.fetch_or_store([method, public, safe].hash) do
              if public
                ::Class.new(PublicCall) do
                  include PublicCall.call_interface(method, safe)
                end
              elsif safe
                PrivateCall
              else
                PrivateSafeCall
              end
            end
          end

          # Coercion with a publicly accessible method call
          #
          # @api private
          class PublicCall < MethodCall
            @interfaces = ::Concurrent::Map.new

            # Choose or build the interface
            #
            # @return [::Module]
            def self.call_interface(method, safe)
              @interfaces.fetch_or_store([method, safe].hash) do
                ::Module.new do
                  if safe
                    module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
                      def call(input, &block)
                        @target.#{method}(input, &block)
                      end
                    RUBY
                  else
                    module_eval(<<~RUBY, __FILE__, __LINE__ + 1)
                      def call(input, &block)
                        @target.#{method}(input)
                      rescue NoMethodError, TypeError, ArgumentError => error
                        CoercionError.handle(error, &block)
                      end
                    RUBY
                  end
                end
              end
            end
          end

          # Coercion via a private method call
          #
          # @api private
          class PrivateCall < MethodCall
            def call(input, &block)
              @target.send(@name, input, &block)
            end
          end

          # Coercion via an unsafe private method call
          #
          # @api private
          class PrivateSafeCall < PrivateCall
            def call(input, &block)
              @target.send(@name, input)
            rescue NoMethodError, TypeError, ArgumentError => e
              CoercionError.handle(e, &block)
            end
          end

          # @api private
          #
          # @return [MethodCall]
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

        # Choose or build specialized invokation code for a callable
        #
        # @param [#call] fn
        # @return [Function]
        def self.[](fn)
          raise ArgumentError, 'Missing constructor block' if fn.nil?

          if fn.is_a?(Function)
            fn
          elsif fn.is_a?(::Method)
            MethodCall[fn, yields_block?(fn)]
          elsif yields_block?(fn)
            new(fn)
          else
            Safe.new(fn)
          end
        end

        # @return [Boolean]
        def self.yields_block?(fn)
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

        # @return [Object]
        def call(input, &block)
          @fn.(input, &block)
        end
        alias_method :[], :call

        # @return [Array]
        def to_ast
          if fn.is_a?(::Proc)
            [:id, Dry::Types::FnContainer.register(fn)]
          else
            [:callable, fn]
          end
        end

        if RUBY_VERSION >= '2.6'
          # @return [Function]
          def >>(other)
            proc = other.is_a?(::Proc) ? other : other.fn
            Function[@fn >> proc]
          end

          # @return [Function]
          def <<(other)
            proc = other.is_a?(::Proc) ? other : other.fn
            Function[@fn << proc]
          end
        else
          # @return [Function]
          def >>(other)
            proc = other.is_a?(::Proc) ? other : other.fn
            Function[-> x { proc[@fn[x]] }]
          end

          # @return [Function]
          def <<(other)
            proc = other.is_a?(::Proc) ? other : other.fn
            Function[-> x { @fn[proc[x]] }]
          end
        end
      end
    end
  end
end
