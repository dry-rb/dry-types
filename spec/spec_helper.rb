$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'dry/data'

begin
  require 'byebug'
rescue LoadError; end
