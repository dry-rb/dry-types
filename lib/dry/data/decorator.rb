module Dry
  module Data
    module Decorator
      attr_reader :type, :options

      def initialize(type, options = {})
        @type = type
        @options = options
      end

      def constructor
        type.constructor
      end

      def valid?(input)
        type.valid?(input)
      end

      def respond_to_missing?(meth, include_private = false)
        super || type.respond_to?(meth)
      end

      def with(new_options)
        self.class.new(type, options.merge(new_options))
      end

      private

      def method_missing(meth, *args, &block)
        if type.respond_to?(meth)
          response = type.__send__(meth, *args, &block)

          if response.kind_of?(type.class)
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
