require 'dry/types/fn_container'

module Dry
  module Types
    class Hash < Definition
      # The built-in Hash type can be defined in terms of keys and associated types
      # its values can contain. Such definitions are named {Schema}s and defined
      # as lists of {Key} types.
      #
      # @see Dry::Types::Hash::Key
      #
      # {Schema} evaluates default values for keys missing in input hash
      #
      # @see Dry::Types::Default#evaluate
      # @see Dry::Types::Default::Callable#evaluate
      #
      # {Schema} implements Enumerable using its keys as collection.
      class Schema < Hash
        NO_TRANSFORM = Dry::Types::FnContainer.register { |x| x }
        SYMBOLIZE_KEY = Dry::Types::FnContainer.register(:to_sym.to_proc)

        include ::Enumerable

        # @return [Array[Dry::Types::Hash::Key]]
        attr_reader :keys

        # @return [Hash[Symbol, Dry::Types::Hash::Key]]
        attr_reader :name_key_map

        # @return [#call]
        attr_reader :transform_key

        # @param [Class] _primitive
        # @param [Hash] options
        # @option options [Array[Dry::Types::Hash::Key]] :keys
        # @option options [String] :key_transform_fn
        def initialize(_primitive, **options)
          @keys = options.fetch(:keys)
          @name_key_map = keys.each_with_object({}) do |key, idx|
            idx[key.name] = key
          end

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
              result = try_coerce(hash) do |key, key_result|
                success &&= key_result.success?
                output[key.name] = key_result.input

                key_result
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
              keys.map { |key| key.to_ast(meta: meta) },
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
          keys = merge_keys(self.keys, build_keys(type_map))
          Schema.new(primitive, **options, keys: keys, meta: meta)
        end

        # Iterate over each key type
        #
        # @return [Array<Dry::Types::Hash::Key>,Enumerator]
        def each(&block)
          keys.each(&block)
        end

        # Whether the schema has the given key
        #
        # @param [Symbol] name Key name
        # @return [Boolean]
        def key?(name)
          name_key_map.key?(name)
        end

        # Fetch key type by a key name.
        # Behaves as ::Hash#fetch
        #
        # @overload key(name, fallback = Undefined)
        #   @param [Symbol] name Key name
        #   @param [Object] fallback Optional fallback, returned if key is missing
        #   @return [Dry::Types::Hash::Key,Object] key type or fallback if key is not in schema
        #
        # @overload key(name, &block)
        #   @param [Symbol] name Key name
        #   @param [Proc] block Fallback block, runs if key is missing
        #   @return [Dry::Types::Hash::Key,Object] key type or block value if key is not in schema
        def key(name, fallback = Undefined, &block)
          if Undefined.equal?(fallback)
            name_key_map.fetch(name, &block)
          else
            name_key_map.fetch(name, fallback)
          end
        end

        private

        def merge_keys(*keys)
          keys.
            flatten(1).
            each_with_object({}) { |key, merged| merged[key.name] = key }.
            values
        end

        def resolve(hash, &block)
          result = {}

          hash.each do |key, value|
            k = transform_key.(key)

            if name_key_map.key?(k)
              result[k] = yield(name_key_map[k], value)
            elsif strict?
              raise UnknownKeysError.new(*unexpected_keys(hash.keys))
            end
          end

          if result.size < keys.size
            resolve_missing_keys(result, &block)
          end

          result
        end

        def resolve_missing_keys(result)
          keys.each do |key|
            next if result.key?(key.name)

            if key.default?
              result[key.name] = yield(key, Undefined)
            elsif key.required?
              raise MissingKeyError, key.name
            end
          end
        end

        # @param keys [Array<Symbol>]
        # @return [Array<Symbol>]
        def unexpected_keys(keys)
          keys.map(&transform_key) - name_key_map.keys
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def try_coerce(hash)
          resolve(hash) do |key, value|
            yield(key, key.try(value))
          end
        end

        # @param [Hash] hash
        # @return [Hash{Symbol => Object}]
        def coerce(hash)
          resolve(hash) do |key, value|
            begin
              key.(value)
            rescue ConstraintError => e
              raise SchemaError.new(key.name, value, e.result)
            rescue TypeError, ArgumentError => e
              raise SchemaError.new(key.name, value, e.message)
            end
          end
        end
      end
    end
  end
end
