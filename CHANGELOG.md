# v0.9.0 2016-09-21

## Added

* `Hash#strict_with_defaults` which validates presence of all required keys and respects default types for missing *values* (backus)
* `Type#constrained?` method (flash-gordon)

## Fixed

* Summing two constrained types works correctly (flash-gordon)
* `Types::Array::Member#valid?` in cases where member type is a constraint (solnic)
* `Hash::Schema#try` handles exceptions properly and returns a failure object (solnic)

## Changed

* [BREAKING] Renamed `Hash##{schema=>permissive}` (backus)
* [BREAKING] `dry-monads` dependency was made optional, Maybe types are available after `Dry::Types.load_extensions(:maybe)` (flash-gordon)
* [BREAKING] `Dry::Types::Struct` and `Dry::Types::Value` have been extracted to [`dry-struct`](https://github.com/dry-rb/dry-struct) (backus)
* `Types::Form::Bool` supports upcased true/false values (kirs)
* `Types::Form::{Date,DateTime,Time}` fail gracefully for invalid input (padde)
* ice_nine dependency has been dropped as it was required by Struct only (flash-gordon)

[Compare v0.8.1...v0.9.0](https://github.com/dryrb/dry-types/compare/v0.8.1...v0.9.0)

# v0.8.1 2016-07-13

## Fixed

* Compiler no longer chokes on type nodes without args (solnic)
* Removed `bin/console` from gem package (solnic)

[Compare v0.8.0...v0.8.1](https://github.com/dryrb/dry-types/compare/v0.8.0...v0.8.1)

# v0.8.0 2016-07-01

## Added

* `Struct` now implements `Type` interface so ie `SomeStruct | String` works now (flash-gordon)
* `:weak` Hash constructor which can partially coerce a hash even when it includes invalid values (solnic)
* Types include `Dry::Equalizer` now (flash-gordon)

## Fixed

* `Struct#to_hash` descends into arrays too (nepalez)
* `Default#with` works now (flash-gordon)

## Changed

* `:symbolized` hash schema is now based on `:weak` schema (solnic)
* `Struct::Value` instances are now **deeply frozen** via ice_nine (backus)

[Compare v0.7.2...v0.8.0](https://github.com/dryrb/dry-types/compare/v0.7.2...v0.8.0)

# v0.7.2 2016-05-11

## Fixed

- `Bool#default` gladly accepts `false` as its value (solnic)
- Creating an empty schema with input processor no longer fails (lasseebert)

## Changed

- Allow multiple calls to meta (solnic)
- Allow capitalised versions of true and false values for boolean coercions (nil0bject)
- Replace kleisli with dry-monads (flash-gordon)
- Use coercions from Kernel (flash-gordon)
- Decimal coercions now work with Float (flash-gordon)
- Coerce empty strings in form posts to blank arrays and hashes (timriley)
- update to use dry-logic v0.2.3 (fran-worley)

[Compare v0.7.1...v0.7.2](https://github.com/dryrb/dry-types/compare/v0.7.1...v0.7.2)

# v0.7.1 2016-04-06

## Added

- `JSON::*` types with JSON-specific coercions (coop)

## Fixed

- Schema is properly inherited in Struct (backus)
- `constructor_type` is properly inherited in Struct (fbernier)

[Compare v0.7.0...v0.7.1](https://github.com/dryrb/dry-types/compare/v0.7.0...v0.7.1)

# v0.7.0 2016-03-30

Major focus of this release is to make complex type composition possible and improving constraint errors to be more meaningful.

## Added

- `Type#try` interface that tries to process the input and return a result object which can be either a success or failure (solnic)
- `#meta` interface for setting arbitrary meta data on types (solnic)
- `ConstraintError` has a message which includes information about the predicate which failed ie `nil violates constraints (type?(String) failed)` (solnic)
- `Struct` uses `Dry::Equalizer` too, just like `Value` (AMHOL)
- `Sum::Constrained` which has a disjunction rule built from its types (solnic)
- Compiler supports `[:constructor, [primitive, fn_proc]]` nodes (solnic)
- Compiler supports building schema-less `form.hash` types (solnic)

## Fixed

- `Sum` now supports complex types like `Array` or `Hash` with member types and/or constraints (solnic)
- `Default#constrained` will properly wrap a new constrained type (solnic)

## Changed

- [BREAKING] Renamed `Type#{optional=>maybe}` (AMHOL)
- [BREAKING] `Type#optional(other)` builds a sum: `Strict::Nil | other` (AMHOL)
- [BREAKING] Type objects are now frozen (solnic)
- [BREAKING] `Value` instances are frozen (AMHOL)
- `Array` is no longer a constructor and has a `Array::Member` subclass (solnic)
- `Hash` is no longer a constructor and is split into `Hash::Safe`, `Hash::Strict` and `Hash::Symbolized` (solnic)
- `Constrained` has now a `Constrained::Coercible` subclass which will try to apply its type prior applying its rule (solnic)
- `#maybe` uses `Strict::Nil` now (solnic)
- `Type#default` will raise if `nil` was passed for `Maybe` type (solnic)
- `Hash` with a schema will set maybe values for missing keys or nils (flash-gordon)

[Compare v0.6.0...v0.7.0](https://github.com/dryrb/dry-types/compare/v0.6.0...v0.7.0)

# v0.6.0 2016-03-16

Renamed from `dry-data` to `dry-types` and:

## Added

* `Dry::Types.module` which returns a namespace for inclusion which has all
  built-in types defined as constants (solnic)
* `Hash#schema` supports default values now (solnic)
* `Hash#symbolized` passes through keys that are already symbols (solnic)
* `Struct.new` uses an empty hash by default as input (solnic)
* `Struct.constructor_type` macro can be used to change attributes constructor (solnic)
* `default` accepts a block now for dynamic values (solnic)
* `Types.register_class` accepts a second arg which is the name of the class'
  constructor method, defaults to `:new` (solnic)

## Fixed

* `Struct` will simply pass-through the input if it is already a struct (solnic)
* `default` will raise if a value violates constraints (solnic)
* Evaluating a default value tries to use type's constructor which makes it work
  with types that may coerce an input into nil (solnic)
* `enum` works just fine with integer-values (solnic)
* `enum` + `default` works just fine (solnic)
* `Optional` no longer responds to `primitive` as it makes no sense since there's
  no single primitive for an optional value (solnic)
* `Optional` passes-through a value which is already a maybe (solnic)

## Changed

* `Dry::Types::Definition` is now the base type definition object (solnic)
* `Dry::Types::Constructor` is now a type definition with a constructor function (solnic)

[Compare v0.5.1...v0.6.0](https://github.com/dryrb/dry-types/compare/v0.5.1...v0.6.0)

# v0.5.1 2016-01-11

## Added

* `Dry::Data::Type#safe` for types which can skip constructor when primitive does
  not match input's class (solnic)
* `form.array` and `form.hash` safe types (solnic)

[Compare v0.5.0...v0.5.1](https://github.com/dryrb/dry-types/compare/v0.5.0...v0.5.1)

# v0.5.0 2016-01-11

## Added

* `Type#default` interface for defining a type with a default value (solnic)

## Changed

* [BREAKING] `Dry::Data::Type.new` accepts constructor and *options* now (solnic)
* Renamed `Dry::Data::Type::{Enum,Constrained}` => `Dry::Data::{Enum,Constrained}` (solnic)
* `dry-logic` is now a dependency for constrained types (solnic)
* Constrained types are now always available (solnic)
* `strict.*` category uses constrained types with `:type?` predicate (solnic)
* `SumType#call` no longer needs to rescue from `TypeError` (solnic)

## Fixed

* `attribute` raises proper error when type definition is missing (solnic)

[Compare v0.4.2...v0.5.0](https://github.com/dryrb/dry-types/compare/v0.4.2...v0.5.0)

# v0.4.2 2015-12-27

## Added

* Support for arrays in type compiler (solnic)

## Changed

* Array member uses type objects now rather than just their constructors (solnic)

[Compare v0.4.1...v0.4.2](https://github.com/dryrb/dry-types/compare/v0.4.1...v0.4.2)

# v0.4.0 2015-12-11

## Added

* Support for sum-types with constraint type (solnic)
* `Dry::Data::Type#optional` for defining optional types (solnic)

## Changed

* `Dry::Data['optional']` was **removed** in favor of `Dry::Data::Type#optional` (solnic)

[Compare v0.3.2...v0.4.0](https://github.com/dryrb/dry-types/compare/v0.3.2...v0.4.0)

# v0.3.2 2015-12-10

## Added

* `Dry::Data::Value` which works like a struct but is a value object with equalizer (solnic)

## Fixed

* Added missing require for `dry-equalizer` (solnic)

[Compare v0.3.1...v0.3.2](https://github.com/dryrb/dry-types/compare/v0.3.1...v0.3.2)

# v0.3.1 2015-12-09

## Changed

* Removed require of constrained type and make it optional (solnic)

[Compare v0.3.0...v0.3.1](https://github.com/dryrb/dry-types/compare/v0.3.0...v0.3.1)

# v0.3.0 2015-12-09

## Added

* `Type#constrained` interface for defining constrained types (solnic)
* `Dry::Data` can be configured with a type namespace (solnic)
* `Dry::Data.finalize` can be used to define types as constants under configured namespace (solnic)
* `Dry::Data::Type#enum` for defining an enum from a specific type (solnic)
* New types: `symbol` and `class` along with their `strict` versions (solnic)

[Compare v0.2.1...v0.3.0](https://github.com/dryrb/dry-types/compare/v0.2.1...v0.3.0)

# v0.2.1 2015-11-30

## Added

* Type compiler supports nested hashes now (solnic)

## Fixed

* `form.bool` sum is using correct right-side `form.false` type (solnic)

## Changed

* Improved structure of the ast (solnic)

[Compare v0.2.0...v0.2.1](https://github.com/dryrb/dry-types/compare/v0.2.0...v0.2.1)

# v0.2.0 2015-11-29

## Added

* `form.nil` which coerces empty strings to `nil` (solnic)
* `bool` sum-type (true | false) (solnic)
* Type compiler supports sum-types now (solnic)

## Changed

* Constructing optional types uses the new `Dry::Data["optional"]` built-in type (solnic)

[Compare v0.1.0...v0.2.0](https://github.com/dryrb/dry-types/compare/v0.1.0...v0.2.0)

# v0.1.0 2015-11-27

## Added

* `form.*` coercible types (solnic)
* `Type::Hash#strict` for defining hashes with a strict schema (solnic)
* `Type::Hash#symbolized` for defining hashes that will symbolize keys (solnic)
* `Dry::Data.register_class` short-cut interface for registering a class and
  setting its `.new` method as the constructor (solnic)
* `Dry::Data::Compiler` for building a type from a simple ast (solnic)

[Compare v0.0.1...HEAD](https://github.com/dryrb/dry-types/compare/v0.0.1...HEAD)

# v0.0.1 2015-10-05

First public release
