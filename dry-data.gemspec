# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dry/data/version'

Gem::Specification.new do |spec|
  spec.name          = "dry-data"
  spec.version       = Dry::Data::VERSION.dup
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.license       = 'MIT'

  spec.summary       = 'Simple type-system for Ruby'
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/dryrb/dry-data"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thread_safe', '~> 0.3'
  spec.add_runtime_dependency 'dry-container', '~> 0.2'
  spec.add_runtime_dependency 'inflecto', '~> 0.0.0', '>= 0.0.2'
  spec.add_runtime_dependency 'kleisli', '~> 0.2'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
