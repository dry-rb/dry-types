source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'dry-equalizer', github: 'dry-rb/dry-equalizer'

group :test do
  platform :mri do
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
