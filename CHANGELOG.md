# v0.3.0 to-be-released

## Added

* `Type#constrained` interface for defining constrained types (solnic)
* `Dry::Data` can be configured with a type namespace (solnic)
* `Dry::Data.finalize` can be used to define types as constants under configured namespace (solnic)
* `Dry::Data::Type#enum` for defining an enum from a specific type (solnic)
* New types: `symbol` and `class` along with their `strict` versions (solnic)

[Compare v0.2.1...v0.3.0](https://github.com/dryrb/dry-data/compare/v0.2.1...v0.3.0)

# v0.2.1 2015-11-30

## Added

* Type compiler supports nested hashes now (solnic)

## Fixed

* `form.bool` sum is using correct right-side `form.false` type (solnic)

## Changed

* Improved structure of the ast (solnic)

[Compare v0.2.0...v0.2.1](https://github.com/dryrb/dry-data/compare/v0.2.0...v0.2.1)

# v0.2.0 2015-11-29

## Added

* `form.nil` which coerces empty strings to `nil` (solnic)
* `bool` sum-type (true | false) (solnic)
* Type compiler supports sum-types now (solnic)

## Changed

* Constructing optional types uses the new `Dry::Data["optional"]` built-in type (solnic)

[Compare v0.1.0...v0.2.0](https://github.com/dryrb/dry-data/compare/v0.1.0...v0.2.0)

# v0.1.0 2015-11-27

## Added

* `form.*` coercible types (solnic)
* `Type::Hash#strict` for defining hashes with a strict schema (solnic)
* `Type::Hash#symbolized` for defining hashes that will symbolize keys (solnic)
* `Dry::Data.register_class` short-cut interface for registering a class and
  setting its `.new` method as the constructor (solnic)
* `Dry::Data::Compiler` for building a type from a simple ast (solnic)

[Compare v0.0.1...HEAD](https://github.com/dryrb/dry-data/compare/v0.0.1...HEAD)

# v0.0.1 2015-10-05

First public release
