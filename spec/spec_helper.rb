# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/warnings"
require_relative "support/rspec_options"

require "pathname"

SPEC_ROOT = Pathname(__FILE__).dirname

require "dry-types"

begin
  require "pry-byebug"
rescue LoadError; end
Dir[Pathname(__dir__).join("shared/*.rb")].each(&method(:require))
require "dry/types/spec/types"

Undefined = Dry::Core::Constants::Undefined

require "dry/core/deprecations"
Dry::Core::Deprecations.set_logger!(SPEC_ROOT.join("../log/deprecations.log"))

RSpec.configure do |config|
  config.before(:example, :maybe) do
    Dry::Types.load_extensions(:maybe)
  end

  config.before do
    @types = Dry::Types.container._container.keys
  end

  config.before { stub_const("Test", Module.new) }

  config.order = "random"
end

srand RSpec.configuration.seed
