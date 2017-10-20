module Dry
  module Types
    class Hash < Definition
      # The built-in Hash type has constructors that you can use to define
      # hashes with explicit schemas and coercible values using the built-in types.
      #
      # Basic {Schema} evaluates default values for keys missing in input hash
      # (see {Schema#resolve_missing_value})
      #
      # @see Dry::Types::Default#evaluate
      # @see Dry::Types::Default::Callable#evaluate
      class Schema < Hash
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

        def hash_type
          :schema
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

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def resolve(hash)
          result = {}
          member_types.each do |key, type|
            if hash.key?(key)
              result[key] = yield(type, key, hash[key])
            else
              resolve_missing_value(result, key, type)
            end
          end
          result
        end

        # @param [Hash] result
        # @param [Symbol] key
        # @param [Type] type
        # @return [Object]
        # @see Dry::Types::Default#evaluate
        # @see Dry::Types::Default::Callable#evaluate
        def resolve_missing_value(result, key, type)
          if type.default?
            result[key] = type.evaluate
          else
            super
          end
        end
      end

      # Permissive schema raises a {MissingKeyError} if the given key is missing
      # in provided hash.
      class Permissive < Schema
        private

        def hash_type
          :permissive
        end

        # @param [Symbol] key
        # @raise [MissingKeyError] when key is missing in given input
        def resolve_missing_value(_, key, _)
          raise MissingKeyError, key
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
      class Strict < Permissive
        private

        def hash_type
          :strict
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        # @raise [UnknownKeysError]
        #   if there any unexpected key in given hash
        # @raise [MissingKeyError]
        #   if a required key is not present
        # @raise [SchemaError]
        #   if a value is the wrong type
        def resolve(hash)
          unexpected = hash.keys - member_types.keys
          raise UnknownKeysError.new(*unexpected) unless unexpected.empty?

          super do |member_type, key, value|
            type = member_type.default? ? member_type.type : member_type

            yield(type, key, value)
          end
        end
      end

      # {StrictWithDefaults} checks that there are no extra keys
      # (raises {UnknownKeysError} otherwise) and there a no missing keys
      # without default values given (raises {MissingKeyError} otherwise).
      # @see Default#evaluate
      # @see Default::Callable#evaluate
      class StrictWithDefaults < Strict
        private

        def hash_type
          :strict_with_defaults
        end

        # @param [Hash] result
        # @param [Symbol] key
        # @param [Type] type
        # @return [Object]
        # @see Dry::Types::Default#evaluate
        # @see Dry::Types::Default::Callable#evaluate
        def resolve_missing_value(result, key, type)
          if type.default?
            result[key] = type.evaluate
          else
            super
          end
        end
      end

      # Weak schema provides safe types for every type given in schema hash
      # @see Safe
      class Weak < Schema
        # @param [Class] primitive
        # @param [Hash] options
        # @see #initialize
        def self.new(primitive, options)
          member_types = options.
            fetch(:member_types).
            each_with_object({}) { |(k, t), res| res[k] = t.safe }

          super(primitive, options.merge(member_types: member_types))
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

        def hash_type
          :weak
        end
      end

      # {Symbolized} hash will turn string key names into symbols.
      class Symbolized < Weak
        private

        def hash_type
          :symbolized
        end

        def resolve(hash)
          result = {}
          member_types.each do |key, type|
            keyname =
              if hash.key?(key)
                key
              elsif hash.key?(string_key = key.to_s)
                string_key
              end

            if keyname
              result[key] = yield(type, key, hash[keyname])
            else
              resolve_missing_value(result, key, type)
            end
          end
          result
        end
      end

      private_constant(*constants(false))
    end
  end
end
