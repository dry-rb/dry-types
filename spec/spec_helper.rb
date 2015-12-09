$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'dry-data'
require 'dry/data/type/constrained'

begin
  require 'byebug'
rescue LoadError; end

Dir[Pathname(__dir__).join('shared/*.rb')].each(&method(:require))
