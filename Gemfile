# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-monads", github: "dry-rb/dry-monads", branch: "main"

group :test do
  gem "dry-struct", github: "dry-rb/dry-struct", branch: "main"
end

group :tools do
  gem "pry-byebug", platform: :mri
end

group :benchmarks do
  platform :mri do
    gem "attrio"
    gem "benchmark-ips"
    gem "fast_attributes"
    gem "hotch"
    gem "virtus"
  end
end
