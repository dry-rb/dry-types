require 'dry/core/deprecations'

Dry::Core::Deprecations.warn('Form types were renamed to Params', tag: :'dry-types')

module Dry
  module Types
    container.keys.grep(/^params\./).each do |key|
      next if key == 'params.integer'
      register(key.sub('params.', 'form.'), container[key])
    end

    register('form.int', self['params.integer'])
  end
end
