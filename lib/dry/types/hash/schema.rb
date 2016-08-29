module Dry
  module Types
    class Hash < Definition
      class Schema < Hash
        attr_reader :member_types

        def initialize(_primitive, options)
          @member_types = options.fetch(:member_types)
          super
        end

        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type.public_send(meth, hash.fetch(key))
            else
              resolve_missing_value(result, key, type)
            end
          end
        end
        alias_method :[], :call

        def try(hash, &block)
          result = call(hash, :try)
          output = result.each_with_object({}) { |(key, res), h| h[key] = res.input }

          if result.values.all?(&:success?)
            success(output)
          else
            failure = failure(output, result)
            block ? yield(failure) : failure
          end
        end

        private

        def resolve_missing_value(result, key, type)
          if type.default?
            result[key] = type.evaluate
          elsif type.maybe?
            result[key] = type[nil]
          end
        end
      end

      class Permissive < Schema
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            begin
              value = hash.fetch(key)
              result[key] = type.public_send(meth, value)
            rescue TypeError
              raise SchemaError.new(key, value)
            rescue KeyError
              raise MissingKeyError.new(key)
            end
          end
        end
        alias_method :[], :call
      end

      class Strict < Schema
        def call(hash, meth = :call)
          unexpected = hash.keys - member_types.keys
          raise UnknownKeysError.new(*unexpected) unless unexpected.empty?

          member_types.each_with_object({}) do |(key, type), result|
            begin
              value = hash.fetch(key)
              result[key] = type.public_send(meth, value)
            rescue TypeError
              raise SchemaError.new(key, value)
            rescue KeyError
              raise MissingKeyError.new(key)
            end
          end
        end
        alias_method :[], :call
      end

      class Weak < Schema
        def self.new(primitive, options)
          member_types = options.
            fetch(:member_types, {}).
            each_with_object({}) { |(k, t), res| res[k] = t.safe }

          super(primitive, options.merge(member_types: member_types))
        end

        def try(hash, &block)
          if hash.is_a?(::Hash)
            super
          else
            result = failure(hash, "#{hash} must be a hash")
            block ? yield(result) : result
          end
        end
      end

      class Symbolized < Weak
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type.public_send(meth, hash.fetch(key))
            else
              key_name = key.to_s

              if hash.key?(key_name)
                result[key] = type.public_send(meth, hash.fetch(key_name))
              else
                resolve_missing_value(result, key, type)
              end
            end
          end
        end
        alias_method :[], :call
      end
    end
  end
end
