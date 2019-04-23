# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :test do
  platform :mri do
    gem 'simplecov', require: false
  end
end

group :tools do
  gem 'pry-byebug', platform: :mri
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'hotch'
  gem 'virtus'
  gem 'fast_attributes'
  gem 'attrio'
  gem 'dry-struct'
end
