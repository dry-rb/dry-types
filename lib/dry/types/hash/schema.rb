module Dry
  module Types
    class Hash < Definition
      class Schema < Hash
        def try(hash, &block)
          result = call(hash, :try)

          if result.values.all?(&:success?)
            success(result.each_with_object({}) { |(key, res), h| h[key] = res.input })
          else
            failure = failure(hash, result)
            block ? yield(failure) : failure
          end
        end

        def member_types
          options[:member_types]
        end
      end

      class Safe < Schema
        def call(hash, meth = :call)
          member_types.each_with_object({}) do |(key, type), result|
            if hash.key?(key)
              result[key] = type.__send__(meth, hash[key])
            elsif type.is_a?(Default)
              result[key] = type.evaluate
            elsif type.is_a?(Maybe)
              result[key] = type[nil]
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
              elsif type.is_a?(Default)
                result[key] = type.evaluate
              elsif type.is_a?(Maybe)
                result[key] = type[nil]
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
