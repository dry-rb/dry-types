module Dry
  module Types
    class Hash < Definition
      class Schema < Hash
        attr_reader :member_types

        def initialize(_primitive, options)
          @member_types = options.fetch(:member_types)
          super
        end

        def call(hash)
          coerce(hash)
        end
        alias_method :[], :call

        def try(hash, &block)
          success = true
          output  = {}

          result =
            try_coerce(hash) do |key, member_result|
              success &&= member_result.success?
              output[key] = member_result.input

              member_result
            end

          if success
            success(output)
          else
            failure = failure(output, result)
            block ? yield(failure) : failure
          end
        end

        private

        def try_coerce(hash)
          resolve(hash) do |type, key, value|
            yield(key, type.try(value))
          end
        end

        def coerce(hash)
          resolve(hash) do |type, key, value|
            begin
              type.call(value)
            rescue ConstraintError
              raise SchemaError.new(key, value)
            end
          end
        end

        def resolve(hash)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = yield(type, key, hash[key])
            else
              resolve_missing_value(result, key, type)
            end
          end
        end

        def resolve_missing_value(result, key, type)
          if type.default?
            result[key] = type.evaluate
          elsif type.maybe?
            result[key] = type[nil]
          end
        end
      end

      class Permissive < Schema
        private

        def resolve_missing_value(_, key, _)
          raise MissingKeyError, key
        end
      end

      class Strict < Permissive
        private

        def resolve(hash)
          unexpected = hash.keys - member_types.keys
          raise UnknownKeysError.new(*unexpected) unless unexpected.empty?

          super do |member_type, key, value|
            type = member_type.default? ? member_type.type : member_type

            yield(type, key, value)
          end
        end
      end

      class StrictWithDefaults < Strict
        private

        def resolve_missing_value(result, key, type)
          if type.default?
            result[key] = type.value
          else
            super
          end
        end
      end

      class Weak < Schema
        def self.new(primitive, options)
          member_types = options.
            fetch(:member_types).
            each_with_object({}) { |(k, t), res| res[k] = t.safe }

          super(primitive, options.merge(member_types: member_types))
        end

        def try(hash, &block)
          if hash.instance_of?(::Hash)
            super
          else
            result = failure(hash, "#{hash} must be a hash")
            block ? yield(result) : result
          end
        end
      end

      class Symbolized < Weak
        private

        def resolve(hash)
          member_types.each_with_object({}) do |(key, type), result|
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
        end
      end

      private_constant(*constants(false))
    end
  end
end
