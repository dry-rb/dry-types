source 'https://rubygems.org'

gemspec

gem 'dry-core', github: 'dry-rb/dry-core', branch: 'master'

group :test do
  gem "codeclimate-test-reporter", platform: :rbx, require: false
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'mutant'
  gem 'mutant-rspec'
end

group :benchmarks do
  gem 'sqlite3'
  gem 'activerecord', platform: %i(jruby mri)
  gem 'benchmark-ips'
  gem 'virtus'
  gem 'fast_attributes'
  gem 'attrio'
end
