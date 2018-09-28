require 'dry/types/fn_container'

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
        NO_TRANSFORM = Dry::Types::FnContainer.register { |x| x }
        SYMBOLIZE_KEY = Dry::Types::FnContainer.register(:to_sym.to_proc)

        # @return [Hash{Symbol => Definition}]
        attr_reader :member_types

        # @return [#call]
        attr_reader :transform_key

        # @param [Class] _primitive
        # @param [Hash] options
        # @option options [Hash{Symbol => Definition}] :member_types
        # @option options [String] :key_transform_fn
        def initialize(_primitive, options)
          @member_types = options.fetch(:member_types)

          meta = options[:meta] || EMPTY_HASH
          key_fn = meta.fetch(:key_transform_fn, NO_TRANSFORM)

          @transform_key = Dry::Types::FnContainer[key_fn]

          super
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def call(hash)
          coerce(hash)
        end
        alias_method :[], :call

        # @param [Hash] hash
        # @yieldparam [Failure] failure
        # @yieldreturn [Result]
        # @return [Logic::Result]
        # @return [Object] if coercion fails and a block is given
        def try(hash)
          if hash.is_a?(::Hash)
            success = true
            output  = {}

            begin
              result = try_coerce(hash) do |key, member_result|
                success &&= member_result.success?
                output[key] = member_result.input

                member_result
              end
            rescue ConstraintError, UnknownKeysError, SchemaError, MissingKeyError => e
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
            block_given? ? yield(failure) : failure
          end
        end

        # @param meta [Boolean] Whether to dump the meta to the AST
        # @return [Array] An AST representation
        def to_ast(meta: true)
          [
            :hash_schema,
            [
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

        # Whether the schema rejects unknown keys
        # @return [Boolean]
        def strict?
          meta.fetch(:strict, false)
        end

        # Make the schema intolerant to unknown keys
        # @return [Schema]
        def strict
          meta(strict: true)
        end

        # Injects a key transformation function
        # @param [#call,nil] proc
        # @param [#call,nil] block
        # @return [Schema]
        def with_key_transform(proc = nil, &block)
          fn = proc || block

          if fn.nil?
            raise ArgumentError, "a block or callable argument is required"
          end

          handle = Dry::Types::FnContainer.register(fn)
          meta(key_transform_fn: handle)
        end

        # @param [{Symbol => Definition}] type_map
        # @return [Schema]
        def schema(type_map)
          member_types = self.member_types.merge(transform_types(type_map))
          Schema.new(primitive, **options, member_types: member_types, meta: meta)
        end

        private

        def resolve(hash)
          result = {}

          hash.each do |key, value|
            k = transform_key.(key)

            if member_types.key?(k)
              result[k] = yield(member_types[k], k, value)
            elsif strict?
              raise UnknownKeysError.new(*unexpected_keys(hash.keys))
            end
          end

          if result.size < member_types.size
            resolve_missing_keys(result, &Proc.new)
          end

          result
        end

        def resolve_missing_keys(result)
          member_types.each do |k, type|
            next if result.key?(k)

            if type.default?
              result[k] = yield(type, k, Undefined)
            elsif !type.meta[:omittable]
              raise MissingKeyError, k
            end
          end
        end

        # @param keys [Array<Symbol>]
        # @return [Array<Symbol>]
        def unexpected_keys(keys)
          keys.map(&transform_key) - member_types.keys
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
            rescue TypeError, ArgumentError => e
              raise SchemaError.new(key, value, e.message)
            end
          end
        end
      end
    end
  end
end
