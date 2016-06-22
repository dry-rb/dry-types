require_relative 'hashify'
require 'dry/types/struct/class_interface'

module Dry
  module Types
    class Struct
      extend ClassInterface

      def initialize(attributes)
        attributes.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      def [](name)
        public_send(name)
      end

      def to_hash
        self.class.schema.keys.each_with_object({}) do |key, result|
          result[key] = Hashify[self[key]]
        end
      end
      alias_method :to_h, :to_hash
    end
  end
end
