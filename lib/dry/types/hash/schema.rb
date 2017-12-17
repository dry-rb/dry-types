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
              :base,
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

        def symbolized?
          meta[:symbolized]
        end

        def permissive?
          meta[:permissive]
        end

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
          elsif symbolized? && hash.key?(string_key = key.to_s)
            string_key
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
          if permissive?
            EMPTY_ARRAY
          else
            hash.keys - member_types.keys
          end
        end
      end
    end
  end
end
