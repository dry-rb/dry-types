module Dry
  module Data
    module Struct
      def self.included(klass)
        super
        klass.extend(Mixin)
        Dry::Data.register(klass, klass.method(:new))
      end

      module Mixin
        def attributes(type_def)
          type_def.each do |name, const|
            constructors[name] =
              if const.is_a?(Class)
                Data.types.fetch(name) { Dry::Data.new { |t| t[const.name] } }
              else
                const
              end
          end
          attr_reader(*type_def.keys)
          self
        end

        def constructors
          @constructors ||= {}
        end

        # OH DEAR LORD NOT AGAIN :(
        def const_missing(name)
          Data.types[name.to_s] || super
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
