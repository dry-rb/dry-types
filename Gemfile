# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-monads"

group :test do
  gem "dry-struct"
end

group :benchmarks do
  platform :mri do
    gem "activemodel"
    gem "attrio"
    gem "benchmark-ips"
    gem "fast_attributes"
    # gem "hotch"
    gem "virtus"
  end
end
