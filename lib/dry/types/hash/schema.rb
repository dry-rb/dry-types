module Dry
  module Types
    class Hash < Definition
      class Schema < Hash
        attr_reader :member_types

        def initialize(primitive, options = {})
          @member_types = options.fetch(:member_types)
          super
        end

        def try(hash, &block)
          result = call(hash, :try)

          if result.values.all?(&:success?)
            success(result.each_with_object({}) { |(key, res), h| h[key] = res.input })
          else
            failure = failure(hash, result)
            block ? yield(failure) : failure
          end
        end

        private

        def resolve_missing_value(result, key, type)
          if type.is_a?(Default)
            result[key] = type.evaluate
          elsif type.is_a?(Maybe)
            result[key] = type[nil]
          end
        end
      end

      class Safe < Schema
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type.__send__(meth, hash[key])
            else
              resolve_missing_value(result, key, type)
            end
          end
        end
        alias_method :[], :call
      end

      class Symbolized < Schema
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type.__send__(meth, hash[key])
            else
              key_name = key.to_s

              if hash.key?(key_name)
                result[key] = type.__send__(meth, hash[key_name])
              else
                resolve_missing_value(result, key, type)
              end
            end
          end
        end
        alias_method :[], :call
      end

      class Strict < Schema
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            begin
              value = hash.fetch(key)
              result[key] = type.__send__(meth, value)
            rescue TypeError
              raise SchemaError.new(key, value)
            rescue KeyError
              raise SchemaKeyError.new(key)
            end
          end
        end
        alias_method :[], :call
      end
    end
  end
end
