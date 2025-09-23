# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/warnings"

require "pathname"

SPEC_ROOT = Pathname(__dir__)

require "dry-types"

%w[debug pry-byebug pry].each do |gem|
  require gem
rescue LoadError
  # ignore
else
  break
end

Dir[SPEC_ROOT.join("support", "**", "*.rb")].each(&method(:require))
Dir[SPEC_ROOT.join("shared", "**", "*.rb")].each(&method(:require))
require "dry/types/spec/types"

Warning.process { raise _1 }

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

  config.include Module.new {
    extend RSpec::SharedContext

    let(:undefined) { Dry::Core::Constants::Undefined }
  }
end

srand RSpec.configuration.seed
