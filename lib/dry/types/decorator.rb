module Dry
  module Types
    module Decorator
      attr_reader :type, :options

      def initialize(type, options = {})
        @type = type
        @options = options
      end

      def constructor
        type.constructor
      end

      def try(input, &block)
        type.try(input, &block)
      end

      def with(new_options)
        self.class.new(type, options.merge(new_options))
      end

      def valid?(value)
        type.valid?(value)
      end

      def default?
        type.default?
      end

      def maybe?
        type.maybe?
      end

      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      private

      def decorate?(response)
        response.kind_of?(type.class)
      end

      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if decorate?(response)
            self.class.new(response, options)
          else
            response
          end
        else
          super
        end
      end
    end
  end
end
