require 'dry/types/container'

module Dry
  module Types
    class FnContainer
      # @api private
      def self.container
        @container ||= Container.new
      end

      # @api private
      def self.register(function)
        register_function_name = register_name(function)
        container.register(register_function_name, function) unless container.key?(register_function_name)
        register_function_name
      end

      # @api private
      def self.[](function_name)
        if container.key?(function_name)
          container[function_name]
        else
          function_name
        end
      end

      # @api private
      def self.register_name(function)
        "fn_#{function.object_id}"
      end
    end
  end
end
