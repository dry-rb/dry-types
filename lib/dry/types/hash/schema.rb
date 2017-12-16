require 'dry/core/class_attributes'
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

        def self.new(primitive, meta: EMPTY_HASH, **options)
          super(primitive, **options, meta: { extra_keys: :ignore, **meta })
        end

        # @return [Hash{Symbol => Definition}]
        attr_reader :member_types

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
          if hash.is_a?(::Hash)
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
          else
            success = false
            output = hash
            result = "#{hash} must be a hash"
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

          member_types.each do |k, type|
            key = key(hash, k)

            if !key.equal?(Undefined) || type.default?
              result[k] = yield(type, k, hash.fetch(key, Undefined))
            elsif !type.meta[:omittable]
              raise MissingKeyError, k
            end
          end

          result
        end

        def key(hash, key)
          if hash.key?(key)
            key
          else
            Undefined
          end
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
        defines :extra_keys

        defines :missing_keys

        def self.new(primitive, meta: EMPTY_HASH, **options)
          super(primitive, **options, meta: { **meta, extra_keys: extra_keys })
        end

        def self.build(primitive, options)
          member_types = {}
          options.fetch(:member_types).each do |k, t|
            type = type(hash_type, t)

            member_types[k] = if missing_keys == :ignore
                                type.meta(omittable: true)
                              else
                                type
                              end
          end

          new(primitive, **options, member_types: member_types)
        end

        def self.type(schema, type)
          type = type.safe if schema == :weak || schema == :symbolized

          type = case schema
                 when :strict_with_defaults
                   type
                 when :strict
                   type.type
                 else
                   type.constructor(NIL_TO_UNDEFINED)
                 end if type.default?

          type
        end

        def hash_type
          :"#{ self.class.hash_type }_transformed"
        end
      end

      class LegacySchema < LegacyBase
        hash_type :schema

        extra_keys :ignore

        missing_keys :ignore
      end

      # Permissive schema raises a {MissingKeyError} if the given key is missing
      # in provided hash.
      class Permissive < LegacyBase
        hash_type :permissive

        extra_keys :ignore

        missing_keys :raise
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

        missing_keys :raise
      end

      # {StrictWithDefaults} checks that there are no extra keys
      # (raises {UnknownKeysError} otherwise) and there a no missing keys
      # without default values given (raises {MissingKeyError} otherwise).
      # @see Default#evaluate
      # @see Default::Callable#evaluate
      class StrictWithDefaults < LegacyBase
        hash_type :strict_with_defaults

        extra_keys :raise

        missing_keys :raise
      end

      # Weak schema provides safe types for every type given in schema hash
      # @see Safe
      class Weak < LegacyBase
        hash_type :weak

        extra_keys :ignore

        missing_keys :ignore
      end

      # {Symbolized} hash will turn string key names into symbols.
      class Symbolized < LegacyBase
        hash_type :symbolized

        extra_keys :ignore

        missing_keys :ignore

        private

        def key(hash, key)
          if hash.key?(key)
            key
          elsif hash.key?(string_key = key.to_s)
            string_key
          else
            Undefined
          end
        end
      end

      private_constant(*constants(false))
    end
  end
end
