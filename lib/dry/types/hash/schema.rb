require 'dry/core/class_attributes'
require 'dry/types/hash'

module Dry
  module Types
    class Hash < Definition

      NIL_TO_UNDEFINED = -> v { v.nil? ? Undefined : v }

      # The built-in Hash type has constructors that you can use to define
      # hashes with explicit schemas and coercible values using the built-in types.
      #
      # Basic {Schema} evaluates default values for keys missing in input hash
      # (see {Schema#resolve_missing_value})
      #
      # @see Dry::Types::Default#evaluate
      # @see Dry::Types::Default::Callable#evaluate
      class Schema < Hash
        extend Dry::Core::ClassAttributes

        defines :hash_type

        defines :extra_keys, type: %i(ignore raise).method(:include?).to_proc

        extra_keys :ignore

        # @return [Hash{Symbol => Definition}]
        attr_reader :member_types
        alias_method :types, :member_types

        # @param [Class] _primitive
        # @param [Hash] options
        # @option options [Hash{Symbol => Definition}] :member_types
        def initialize(_primitive, options)
          @member_types = options.fetch(:member_types)
          super
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def call(hash)
          coerce(hash)
        end
        alias_method :[], :call

        # @param [Hash] hash
        # @param [#call,nil] block
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        # @return [Logic::Result]
        # @return [Object] if coercion fails and a block is given
        def try(hash, &block)
          success = true
          output  = {}

          begin
            result = try_coerce(hash) do |key, member_result|
              success &&= member_result.success?
              output[key] = member_result.input

              member_result
            end
          rescue ConstraintError, UnknownKeysError, SchemaError => e
            success = false
            result = e
          end

          if success
            success(output)
          else
            failure = failure(output, result)
            block ? yield(failure) : failure
          end
        end

        def to_ast(meta: true)
          [
            :hash,
            [
              hash_type,
              member_types.map { |name, member| [:member, [name, member.to_ast(meta: meta)]] },
              meta ? self.meta : EMPTY_HASH
            ]
          ]
        end

        # @param [Hash] hash
        # @return [Boolean]
        def valid?(hash)
          result = try(hash)
          result.success?
        end
        alias_method :===, :valid?

        private

        def resolve(hash)
          unexpected = extra_keys(hash)
          raise UnknownKeysError.new(*unexpected) unless unexpected.empty?

          result = {}

          types.each do |k, type|
            key = key(hash, k)

            unless key.equal?(Undefined)
              result[k] = yield(type, k, hash.fetch(key, Undefined))
            end
          end

          result
        end

        def key(_hash, key)
          key
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def try_coerce(hash)
          resolve(hash) do |type, key, value|
            yield(key, type.try(value))
          end
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def coerce(hash)
          resolve(hash) do |type, key, value|
            begin
              type.call(value)
            rescue ConstraintError => e
              raise SchemaError.new(key, value, e.result)
            end
          end
        end

        def extra_keys(hash)
          case meta[:extra_keys]
          when :ignore
            EMPTY_ARRAY
          when :raise
            hash.keys - member_types.keys
          end
        end

        def hash_type
          self.class.hash_type
        end
      end

      class LegacyBase < Schema
        defines :type_processor

        # @return [Hash{Symbol => Definition}]
        attr_reader :types

        # @param [Class] _primitive
        # @param [Hash] options
        # @option options [Hash{Symbol => Definition}] :member_types
        def initialize(_primitive, options)
          @types = {}
          options.fetch(:member_types).each { |k, t| types[k] = self.class.type_processor.(t) }
          super
        end
      end

      class LegacySchema < LegacyBase
        hash_type :schema

        type_processor -> t do
          t.default? ? t.constructor(NIL_TO_UNDEFINED) : t
        end

        private

        def key(hash, key)
          if hash.key?(key) || types[key].default?
            key
          else
            Undefined
          end
        end
      end

      # Permissive schema raises a {MissingKeyError} if the given key is missing
      # in provided hash.
      class Permissive < LegacyBase
        hash_type :permissive

        type_processor -> t do
          t.default? ? t.constructor(NIL_TO_UNDEFINED) : t
        end

        private

        def key(hash, key)
          if hash.key?(key)
            key
          else
            raise MissingKeyError, key
          end
        end
      end

      # Strict hash will raise errors when keys are missing or value types are incorrect.
      # Strict schema raises a {UnknownKeysError} if there are any unexpected
      # keys in given hash, and raises a {MissingKeyError} if any key is missing
      # in it.
      # @example
      #   hash = Types::Hash.strict(name: Types::String, age: Types::Coercible::Int)
      #   hash[email: 'jane@doe.org', name: 'Jane', age: 21]
      #     # => Dry::Types::SchemaKeyError: :email is missing in Hash input
      class Strict < LegacyBase
        hash_type :strict

        extra_keys :raise

        type_processor -> t { t.default? ? t.type : t }

        private

        def key(hash, key)
          if hash.key?(key)
            key
          else
            raise MissingKeyError, key
          end
        end
      end

      # {StrictWithDefaults} checks that there are no extra keys
      # (raises {UnknownKeysError} otherwise) and there a no missing keys
      # without default values given (raises {MissingKeyError} otherwise).
      # @see Default#evaluate
      # @see Default::Callable#evaluate
      class StrictWithDefaults < LegacyBase
        hash_type :strict_with_defaults

        extra_keys :raise

        type_processor -> t { t }

        private

        def key(hash, key)
          if hash.key?(key) || types[key].default?
            key
          else
            raise MissingKeyError, key
          end
        end
      end

      # Weak schema provides safe types for every type given in schema hash
      # @see Safe
      class Weak < LegacyBase
        hash_type :weak

        type_processor -> t do
          if t.default?
            t.safe.constructor(NIL_TO_UNDEFINED)
          else
            t.safe
          end
        end

        # @param [Object] value
        # @param [#call, nil] block
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        # @return [Object] if block given
        # @return [Result,Logic::Result] otherwise
        def try(value, &block)
          if value.is_a?(::Hash)
            super
          else
            result = failure(value, "#{value} must be a hash")
            block ? yield(result) : result
          end
        end

        private

        def key(hash, key)
          if hash.key?(key) || types[key].default?
            key
          else
            Undefined
          end
        end
      end

      # {Symbolized} hash will turn string key names into symbols.
      class Symbolized < Weak
        hash_type :symbolized

        private

        def key(hash, key)
          if hash.key?(key)
            key
          elsif hash.key?(string_key = key.to_s)
            string_key
          elsif types[key].default?
            key
          else
            Undefined
          end
        end
      end

      private_constant(*constants(false))
    end
  end
end
