require 'dry/types/struct'

module Dry
  module Types
    class Value < Struct
      def self.inherited(klass)
        super
        klass.instance_variable_set('@equalizer', Equalizer.new)
        klass.send(:include, klass.equalizer)
      end

      def self.attributes(*args)
        super
        equalizer.instance_variable_get('@keys').concat(schema.keys).uniq!
      end

      def self.equalizer
        @equalizer
      end
    end
  end
end
