require 'dry/core/deprecations'

module Dry
  module Types
    module Builder
      include Dry::Core::Constants

      # @return [Class]
      def constrained_type
        Constrained
      end

      # @return [Class]
      def constructor_type
        Constructor
      end

      # @param [Type] other
      # @return [Sum, Sum::Constrained]
      def |(other)
        klass = constrained? && other.constrained? ? Sum::Constrained : Sum
        klass.new(self, other)
      end

      # @return [Sum]
      def optional
        Types['strict.nil'] | self
      end

      # @param [Hash] options constraining rule (see {Types.Rule})
      # @return [Constrained]
      def constrained(options)
        constrained_type.new(self, rule: Types.Rule(options))
      end

      # @param [Object] input
      # @param [Hash] options
      # @param [#call,nil] block
      # @raise [ConstraintError]
      # @return [Default]
      def default(input = Undefined, options = EMPTY_HASH, &block)
        unless input.frozen? || options[:shared]
          where = Dry::Core::Deprecations::STACK.()
          Dry::Core::Deprecations.warn(
            "#{input.inspect} is mutable."\
            ' Be careful: types will return the same instance of the default'\
            ' value every time. Call `.freeze` when setting the default'\
            ' or pass `shared: true` to discard this warning.'\
            "\n#{ where }",
            tag: :'dry-types'
          )
        end

        value = input.equal?(Undefined) ? block : input

        if value.respond_to?(:call) || valid?(value)
          Default[value].new(self, value)
        else
          raise ConstraintError.new("default value #{value.inspect} violates constraints", value)
        end
      end

      # @param [Array] values
      # @return [Enum]
      def enum(*values)
        mapping =
          if values.length == 1 && values[0].is_a?(::Hash)
            values[0]
          else
            ::Hash[values.zip(values)]
          end

        Enum.new(constrained(included_in: mapping.keys), mapping: mapping)
      end

      # @return [Safe]
      def safe
        Safe.new(self)
      end

      # @param [#call,nil] constructor
      # @param [Hash] options
      # @param [#call,nil] block
      # @return [Constructor]
      def constructor(constructor = nil, **options, &block)
        constructor_type.new(with(options), fn: constructor || block)
      end
    end
  end
end

require 'dry/types/default'
require 'dry/types/constrained'
require 'dry/types/enum'
require 'dry/types/safe'
require 'dry/types/sum'
