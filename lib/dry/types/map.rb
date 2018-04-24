module Dry
  module Types
    class Map < Definition
      def initialize(_primitive, key_type: Types['any'], value_type: Types['any'], meta: EMPTY_HASH)
        super(_primitive, key_type: key_type, value_type: value_type, meta: meta)
        validate_options!
      end

      # @return [Type]
      def key_type
        options[:key_type]
      end

      # @return [Type]
      def value_type
        options[:value_type]
      end

      # @return [String]
      def name
        "Map"
      end

      # @param [Hash] hash
      # @return [Hash]
      def call(hash)
        try(hash) do |failure|
          raise MapError, failure.error.join("\n")
        end.input
      end
      alias_method :[], :call

      # @param [Hash] hash
      # @return [Boolean]
      def valid?(hash)
        coerce(hash).success?
      end
      alias_method :===, :valid?

      # @param [Hash] hash
      # @return [Result]
      def try(hash)
        result = coerce(hash)
        return result if result.success? || !block_given?
        yield(result)
      end

      # @param meta [Boolean] Whether to dump the meta to the AST
      # @return [Array] An AST representation
      def to_ast(meta: true)
        [:map,
         [key_type.to_ast(meta: true), value_type.to_ast(meta: true),
          meta ? self.meta : EMPTY_HASH]]
      end

      private

      def coerce(input)
        return failure(
          input, "#{input.inspect} must be an instance of #{primitive}"
        ) unless primitive?(input)

        output, failures = {}, []

        input.each do |k,v|
          res_k = options[:key_type].try(k)
          res_v = options[:value_type].try(v)
          if res_k.failure?
            failures << "input key #{k.inspect} is invalid: #{res_k.error}"
          elsif output.key?(res_k.input)
            failures << "duplicate coerced hash key #{res_k.input.inspect}"
          elsif res_v.failure?
            failures << "input value #{v.inspect} for key #{k.inspect} is invalid: #{res_v.error}"
          else
            output[res_k.input] = res_v.input
          end
        end

        return success(output) if failures.empty?

        failure(input, failures)
      end

      def validate_options!
        %i(key_type value_type).each do |opt|
          type = send(opt)
          next if type.is_a?(Type)
          raise MapError, ":#{opt} must be a #{Type}, got: #{type.inspect}"
        end
      end
    end
  end
end
