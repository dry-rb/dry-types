# frozen_string_literal: true

module Dry
  module Types
    # @api private
    class Printer
      MAPPING = {
        Definition => :visit_definition,
        Constructor => :visit_constructor,
        Hash::Constructor => :visit_constructor,
        Constrained => :visit_constrained,
        Constrained::Coercible => :visit_constrained,
        Hash => :visit_hash,
        Hash::Schema => :visit_schema,
        Hash::Key => :visit_key,
        Map => :visit_map,
        Array => :visit_array,
        Array::Member => :visit_array_member,
        Safe => :visit_safe,
        Enum => :visit_enum,
        Default => :visit_default,
        Default::Callable => :visit_default,
        Sum => :visit_sum,
        Sum::Constrained => :visit_sum,
        Any.class => :visit_any
      }

      def call(type)
        "#<Dry::Types[#{ visit(type, "".dup) }]>"
      end

      def visit(type, out)
        print_with = MAPPING.fetch(type.class) do
          raise ArgumentError, "Do not know how to print #{ type.class }"
        end
        send(print_with, type, out)
      end

      def visit_any(_type, out)
        out << "Any"
      end

      def visit_array(type, out)
        out << "Array"
      end

      def visit_array_member(type, out)
        out << "Array<#{ visit(type.member, "".dup) }>"
      end

      def visit_constructor(type, out)
        out << "Constructor<"

        visit(type.type, out)
        visit_callable(type.fn, out << " fn=")

        out << options(type, exclude: %i(fn)) << meta(type) << ">"
      end

      def visit_constrained(type, out)
        out << "Constrained<"
        visit(type.type, out)

        rule = type.rule.to_s

        out << " rule=[#{ rule }]"
        out << options(type, exclude: %i(rule)) << meta(type) << ">"
      end

      def visit_schema(type, out)
        out << "Schema<keys={" << type.map { |key| visit(key, "".dup) }.join(", ") << "}"

        out << " strict" if type.strict?

        if type.trasform_keys?
          visit_callable(type.meta[:key_transform_fn], out << " key_fn=")
        end

        if type.transform_types?
          visit_callable(type.meta[:type_transform_fn], out << " type_fn=")
        end

        out << options(type, exclude: %i(keys))
        out << meta(type, exclude: %i(strict key_transform_fn type_transform_fn))
        out << ">"
      end

      def visit_map(type, out)
        out << "Map<"
        visit(type.key_type, out)
        out << " => "
        visit(type.value_type, out)
        out << options(type, exclude: %i(key_type value_type)) << meta(type) << ">"
      end

      def visit_key(type, out)
        key_out = visit(type.type, "".dup).chomp!(">")

        if type.required?
          out << "#{ type.name }: #{ key_out }"
        else
          out << "#{ type.name }?: #{ key_out }"
        end
        out << meta(type) << ">"
      end

      def visit_sum(type, out)
        out << "Sum<"
        visit_sum_constructors(type, out)
        out << options(type) << meta(type) << ">"
      end

      def visit_sum_constructors(type, out)
        case type.left
        when Sum, Sum::Constrained
          visit_sum_constructors(type.left, out)
        else
          visit(type.left, out)
        end

        out << " | "

        case type.right
        when Sum, Sum::Constrained
          visit_sum_constructors(type.right, out)
        else
          visit(type.right, out)
        end
      end

      def visit_enum(type, out)
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
        out << ">"
      end

      def visit_default(type, out)
        out << "Default<"
        visit(type.type, out)

        if type.is_a?(Default::Callable)
          visit_callable(type.value, out << " value_fn=")
        else
          out << " value=#{ type.value.inspect }"
        end

        out << options(type) << meta(type, exclude: %i(strict)) << ">"
      end

      def visit_definition(type, out)
        out << "Definition<#{ type.primitive }"
        out << options(type) << meta(type, exclude: %i(strict)) << ">"
      end

      def visit_safe(type, out)
        out << "Safe<#{ visit(type.type, "".dup) }>"
      end

      def visit_hash(type, out)
        hash_output = "".dup

        if type.transform_types?
          visit_callable(type.meta[:type_transform_fn], hash_output << " type_fn=")
        end

        hash_output << options(type, exclude: %i(keys))
        hash_output << meta(type, exclude: %i(type_transform_fn))

        if hash_output.empty?
          out << "Hash"
        else
          out << "Hash<#{ hash_output }>"
        end
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

      def visit_callable(callable, out)
        fn = callable.is_a?(String) ? FnContainer[callable] : callable

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
            match = fn.to_s.match(/\A#<Proc:0x\h+\(&:(\w+)\)>\z/)

            if match
              out << ".#{ match[1] }"
            else
              out << "(proc)"
            end
          end
        else
          call = fn.method(:call)

          if call.owner == fn.class
            out << "#{ fn.class.to_s }#call"
          else
            out << "#{ fn.to_s }.call"
          end
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
            meta_str = " meta={".dup

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

    PRINTER = Printer.new.freeze
  end
end
