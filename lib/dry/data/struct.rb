module Dry
  module Data
    module Struct
      def self.included(klass)
        super
        klass.extend(Mixin)
        Dry::Data.register(klass.name, klass.method(:new))
      end

      module Mixin
        def attributes(type_def)
          type_def.each do |const, name|
            constructors[name] = Dry::Data.new { |t| t[const.name] }
          end
          attr_reader(*type_def.values)
          self
        end

        def constructors
          @constructors ||= {}
        end
      end

      def initialize(attributes)
        constructors = self.class.constructors

        attributes.each do |key, value|
          instance_variable_set("@#{key}", constructors[key][value])
        end
      end
    end
  end
end
