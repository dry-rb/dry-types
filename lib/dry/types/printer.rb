module Dry
  module Types
    class Printer
      def call(type)
        str = "#<Dry::Types["
        visit(type, str)
        str << "]>"
        str
      end

      def visit(type, out)
        case type
        when Constructor
          out << "Constructor<"

          visit(type.type, out)
          visit_callable(type.fn, out << " fn=")

          out << options(type, exclude: %i(fn))
          out << meta(type)
        when Constrained
          out << "Constrained<"
          visit(type.type, out)

          rule = type.rule.to_s

          out << " rule=[#{ rule }]"

          out << options(type, exclude: %i(rule))
          out << meta(type)
        when Hash::Schema
          out << "Schema<keys={" << type.map { |key, index|
            key_out = ""
            visit(key, key_out)
            key_out
          }.join(", ") << "}"

          out << " strict" if type.strict?

          if type.trasform_keys?
            visit_callable(type.meta[:key_transform_fn], out << " key_fn=")
          end

          if type.transform_types?
            visit_callable(type.meta[:type_transform_fn], out << " type_fn=")
          end

          out << options(type, exclude: %i(keys))
          out << meta(type, exclude: %i(strict key_transform_fn type_transform_fn))
        when Map
          out << "Map<"
          visit(type.key_type, out)
          out << " => "
          visit(type.value_type, out)
          out << options(type, exclude: %i(key_type value_type))
          out << meta(type)
        when Hash::Key
          key_out = ""
          visit(type.type, key_out)
          key_out.chomp!(">")

          if type.required?
            out << "#{ type.name }: #{ key_out }"
          else
            out << "#{ type.name }?: #{ key_out }"
          end
          out << meta(type)
        when Sum, Sum::Constrained
          out << "Sum<"
          visit_sum(type, out)
          out << options(type)
          out << meta(type)
        when Enum
          out << "Enum<"
          visit(type.type, out)

          if type.mapping == type.inverted_mapping
            out << " values={"
            out << type.mapping.values.map(&:inspect).join(", ")
            out << "}"
          else
            out << " mapping={"
            out << type.mapping.map { |key, value|
              "#{ key.inspect }=>#{ value.inspect }"
            }.join(", ")
            out << "}"
          end
          out << options(type, exclude: %i(mapping))
          out << meta(type)
        when Default
          out << "Default<"
          visit(type.type, out)

          if type.is_a?(Default::Callable)
            visit_callable(type.value, out << " value_fn=")
          else
            out << " value=#{ type.value.inspect }"
          end

          out << options(type)
          out << meta(type, exclude: %i(strict))
        when Definition
          out << "Definition<#{ type.primitive }"
          out << options(type)
          out << meta(type, exclude: %i(strict))
        when Safe
          out << "Safe<"
          visit(type.type, out)
        else
          out << "unhandled"
        end

        out << ">"
      end

      def options(type, exclude: EMPTY_ARRAY)
        options = type.options.dup
        exclude.each { |key| options.delete(key) }

        if options.empty?
          EMPTY_STRING
        else
          " options=#{ options.inspect }"
        end
      end

      def visit_sum(type, out)
        case type.left
        when Sum, Sum::Constrained
          visit_sum(type.left, out)
        else
          visit(type.left, out)
        end

        out << " | "

        case type.right
        when Sum, Sum::Constrained
          visit_sum(type.right, out)
        else
          visit(type.right, out)
        end
      end

      def visit_callable(fn, out)
        case fn
        when Method
          out << "#{ fn.receiver }.#{ fn.name }"
        when Proc
          path, line = fn.source_location

          if path
            out << "#{ path.sub(Dir.pwd + "/", EMPTY_STRING) }:#{ line }"
          elsif fn.lambda?
            out << "(lambda)"
          else
            out << "(proc)"
          end
        else
          out << "#{ fn.to_s }.call"
        end
      end

      def meta(type, exclude: EMPTY_ARRAY)
        if type.meta.empty?
          EMPTY_STRING
        else
          meta = type.meta.reject { |k, _| exclude.include?(k) }

          if meta.empty?
            EMPTY_STRING
          else
            meta_str = " meta={"

            values = type.meta.map do |key, value|
              case key
              when Symbol
                "#{ key }: #{ value.inspect }"
              else
                "#{ key.inspect }=>#{ value.inspect }"
              end
            end

            meta_str << values.join(", ") << "}"
          end
        end
      end
    end
  end
end
