require 'dry/core/deprecations'

Dry::Core::Deprecations.warn('Form types were renamed to Params', tag: :'dry-types')

module Dry
  module Types
    container.keys.grep(/^params\./).each do |key|
      next if key.start_with?('params.int')
      register(key.sub('params.', 'form.'), container[key])
    end

    register('form.int', self['params.integer'])
    register('form.integer', self['params.integer'])

    class Compiler
      def visit_form_hash(node)
        schema, meta = node
        merge_with('params.hash', :symbolized, schema).meta(meta)
      end

      def visit_form_array(node)
        member, meta = node
        registry['params.array'].of(visit(member)).meta(meta)
      end
    end
  end
end
