require 'dry/types/container'

module Dry
  module Types
    class FnContainer
      def self.container
        @container ||= Container.new
      end

      def self.register(name, function)
        container.register(name, function) unless container.key?(name)
      end

      def self.[](function_name)
        if container.key?(function_name)
          container[function_name]
        else
          function_name
        end
      end
    end
  end
end
