# frozen_string_literal: true

module Dry
  module Types
    class Map < Nominal
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
      def call_safe(hash)
        try(hash) { |failure| return yield }.input
      end

      def call_unsafe(hash)
        try(hash) { |failure|
          raise MapError, failure.error.message
        }.input
      end

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

      # @return [Boolean]
      def constrained?
        value_type.constrained?
      end

      private

      def coerce(input)
        return failure(
          input, CoercionError.new("#{input.inspect} must be an instance of #{primitive}")
        ) unless primitive?(input)

        output, failures = {}, []

        input.each do |k, v|
          res_k = key_type.try(k)
          res_v = value_type.try(v)

          if res_k.failure?
            failures << res_k.error
          elsif output.key?(res_k.input)
            failures << CoercionError.new("duplicate coerced hash key #{res_k.input.inspect}")
          elsif res_v.failure?
            failures << res_v.error
          else
            output[res_k.input] = res_v.input
          end
        end

        return success(output) if failures.empty?

        failure(input, MultipleError.new(failures))
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
