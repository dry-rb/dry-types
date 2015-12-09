$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'dry/data'

begin
  require 'byebug'
rescue LoadError; end

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each { |const| remove_const(const) }
  end
end

RSpec.configure do |config|
  config.after do
    Test.constants.each do |const|
      key = "test.#{Dry::Data.identifier(const)}"
      Dry::Data.type_map.delete(key)
      Dry::Data.container._container.delete(key)
    end
    Test.remove_constants
  end
end
