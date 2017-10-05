lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/types/version'

Gem::Specification.new do |spec|
  spec.name          = "dry-types"
  spec.version       = Dry::Types::VERSION.dup
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.license       = 'MIT'

  spec.summary       = 'Type system for Ruby supporting coercions, constraints and complex types like structs, value objects, enums etc.'
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/dry-rb/dry-types"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) } - ['bin/console', 'bin/setup']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.2.0"

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'dry-core', '~> 0.2', '>= 0.2.1'
  spec.add_runtime_dependency 'dry-container', '~> 0.3'
  spec.add_runtime_dependency 'dry-equalizer', '~> 0.2'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.1'
  spec.add_runtime_dependency 'dry-logic', '~> 0.4', '>= 0.4.2'
  spec.add_runtime_dependency 'inflecto', '~> 0.0.0', '>= 0.0.2'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency 'dry-monads', '~> 0.2'
  spec.add_development_dependency 'yard', '~> 0.9.5'
end
