require 'dry/types/fn_container'

module Dry
  module Types
    # The built-in Hash type can be defined in terms of keys and associated types
    # its values can contain. Such definitions are named {Schema}s and defined
    # as lists of {Key} types.
    #
    # @see Dry::Types::Schema::Key
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

      # @return [Array[Dry::Types::Schema::Key]]
      attr_reader :keys

      # @return [Hash[Symbol, Dry::Types::Schema::Key]]
      attr_reader :name_key_map

      # @return [#call]
      attr_reader :transform_key

      # @param [Class] _primitive
      # @param [Hash] options
      # @option options [Array[Dry::Types::Schema::Key]] :keys
      # @option options [String] :key_transform_fn
      def initialize(_primitive, **options)
        @keys = options.fetch(:keys)
        @name_key_map = keys.each_with_object({}) do |key, idx|
          idx[key.name] = key
        end

        key_fn = options.fetch(:key_transform_fn, NO_TRANSFORM)

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
      # @option options [Boolean] :skip_missing If true don't raise error if on missing keys
      # @option options [Boolean] :resolve_defaults If false default value
      #                                             won't be evaluated for missing key
      # @return [Hash{Symbol => Object}]
      def apply(hash, options = EMPTY_HASH)
        coerce(hash, options)
      end

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
        if RUBY_VERSION >= "2.5"
          opts = options.slice(:key_transform_fn, :type_transform_fn, :strict)
        else
          opts = options.select { |k, _|
            k == :key_transform_fn || k == :type_transform_fn || k == :strict
          }
        end

        [
          :schema,
          [
            keys.map { |key| key.to_ast(meta: meta) },
            opts,
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
        options.fetch(:strict, false)
      end

      # Make the schema intolerant to unknown keys
      # @return [Schema]
      def strict
        with(strict: true)
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
        with(key_transform_fn: handle)
      end

      # Whether the schema transforms input keys
      # @return [Boolean]
      # @api public
      def trasform_keys?
        !options[:key_transform_fn].nil?
      end

      # @overload schema(type_map, meta = EMPTY_HASH)
      #   @param [{Symbol => Dry::Types::Nominal}] type_map
      #   @param [Hash] meta
      #   @return [Dry::Types::Schema]
      # @overload schema(keys)
      #   @param [Array<Dry::Types::Schema::Key>] key List of schema keys
      #   @param [Hash] meta
      #   @return [Dry::Types::Schema]
      def schema(keys_or_map)
        if keys_or_map.is_a?(::Array)
          new_keys = keys_or_map
        else
          new_keys = build_keys(keys_or_map)
        end

        keys = merge_keys(self.keys, new_keys)
        Schema.new(primitive, **options, keys: keys, meta: meta)
      end

      # Iterate over each key type
      #
      # @return [Array<Dry::Types::Schema::Key>,Enumerator]
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
      #   @return [Dry::Types::Schema::Key,Object] key type or fallback if key is not in schema
      #
      # @overload key(name, &block)
      #   @param [Symbol] name Key name
      #   @param [Proc] block Fallback block, runs if key is missing
      #   @return [Dry::Types::Schema::Key,Object] key type or block value if key is not in schema
      def key(name, fallback = Undefined, &block)
        if Undefined.equal?(fallback)
          name_key_map.fetch(name, &block)
        else
          name_key_map.fetch(name, fallback)
        end
      end

      # @return [Boolean]
      def constrained?
        true
      end

      private

      # @param [Array<Dry::Types::Schema::Keys>] keys
      # @return [Dry::Types::Schema]
      # @api private
      def merge_keys(*keys)
        keys.
          flatten(1).
          each_with_object({}) { |key, merged| merged[key.name] = key }.
          values
      end

      def resolve(hash, options = EMPTY_HASH, &block)
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
          resolve_missing_keys(result, options, &block)
        end

        result
      end

      def resolve_missing_keys(result, options)
        skip_missing = options.fetch(:skip_missing, false)
        resolve_defaults = options.fetch(:resolve_defaults, true)

        keys.each do |key|
          next if result.key?(key.name)

          if key.default? && resolve_defaults
            result[key.name] = yield(key, Undefined)
          elsif key.required? && !skip_missing
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
      def coerce(hash, options = EMPTY_HASH)
        resolve(hash, options) do |key, value|
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
