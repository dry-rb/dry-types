source 'https://rubygems.org'

gemspec

group :test do
  platform :mri do
    gem "codeclimate-test-reporter", require: false
    gem 'simplecov', require: false
  end
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'mutant'
  gem 'mutant-rspec'
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'virtus'
  gem 'fast_attributes'
  gem 'attrio'
  gem 'dry-struct'
end

gem 'dry-logic', git: 'https://github.com/dry-rb/dry-logic'
