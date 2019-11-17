# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'dry-logic', github: 'dry-rb/dry-logic', branch: 'master' if ENV['DRY_LOGIC_FROM_MASTER'].eql?('true')

group :test do
  platform :mri do
    gem 'simplecov', require: false
  end

  gem 'dry-struct'
end

group :tools do
  gem 'pry-byebug', platform: :mri
  gem 'rubocop'
  gem 'ossy', github: 'solnic/ossy', branch: 'master'
end

group :benchmarks do
  platform :mri do
    gem 'attrio'
    gem 'benchmark-ips'
    gem 'dry-struct'
    gem 'fast_attributes'
    gem 'hotch'
    gem 'virtus'
  end
end
