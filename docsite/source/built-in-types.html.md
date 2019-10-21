---
title: Built-in Types
layout: gem-single
name: dry-types
---

Built-in types are grouped under 6 categories:

- `strict` - constrained types with a primitive type check applied to input
- `nominal` - base type definitions with a primitive class and options
- `coercible` - types with constructors using kernel coercions
- `params` - types with constructors performing non-strict coercions specific to HTTP parameters
- `json` - types with constructors performing non-strict coercions specific to JSON
- `maybe` - types accepting either nil or a specific primitive type

### Categories

Assuming you included `Dry::Types` ([see instructions](docs::getting-started)) in a module called `Types`:

* `Strict` types will raise an error if passed a value of the wrong type. `Strict` is the default Type, so `::Strict` can be omitted:
  - `Types.nil`
  - `Types.symbol`
  - `Types.class`
  - `Types.true`
  - `Types.false`
  - `Types.bool`
  - `Types.integer`
  - `Types.float`
  - `Types.decimal`
  - `Types.string`
  - `Types.date`
  - `Types.dateTime`
  - `Types.time`
  - `Types.array`
  - `Types.hash`

* Nominal types:
  - `Types::Nominal::Any`
  - `Types::Nominal::Nil`
  - `Types::Nominal::Symbol`
  - `Types::Nominal::Class`
  - `Types::Nominal::True`
  - `Types::Nominal::False`
  - `Types::Nominal::Bool`
  - `Types::Nominal::Integer`
  - `Types::Nominal::Float`
  - `Types::Nominal::Decimal`
  - `Types::Nominal::String`
  - `Types::Nominal::Date`
  - `Types::Nominal::DateTime`
  - `Types::Nominal::Time`
  - `Types::Nominal::Array`
  - `Types::Nominal::Hash`

> All types in the `strict` category are [constrained](/gems/dry-types/1.0/constraints) by a type-check that is applied to make sure that the input is an instance of the primitive:

``` ruby
Types.integer[1] # => 1
Types.integer['1'] # => raises Dry::Types::ConstraintError
```

* `Coercible` types will attempt to cast values to the correct class using kernel coercion methods:
  - `Types::Coercible::String`
  - `Types::Coercible::Integer`
  - `Types::Coercible::Float`
  - `Types::Coercible::Decimal`
  - `Types::Coercible::Array`
  - `Types::Coercible::Hash`

* Types suitable for `Params` param processing with coercions:
  - `Types::Params::Nil`
  - `Types::Params::Date`
  - `Types::Params::DateTime`
  - `Types::Params::Time`
  - `Types::Params::True`
  - `Types::Params::False`
  - `Types::Params::Bool`
  - `Types::Params::Integer`
  - `Types::Params::Float`
  - `Types::Params::Decimal`
  - `Types::Params::Array`
  - `Types::Params::Hash`

* Types suitable for `JSON` processing with coercions:
  - `Types::JSON::Nil`
  - `Types::JSON::Date`
  - `Types::JSON::DateTime`
  - `Types::JSON::Time`
  - `Types::JSON::Decimal`
  - `Types::JSON::Array`
  - `Types::JSON::Hash`

* `Maybe` strict types:
  - `Types::Maybe::Strict::Class`
  - `Types::Maybe::Strict::String`
  - `Types::Maybe::Strict::Symbol`
  - `Types::Maybe::Strict::True`
  - `Types::Maybe::Strict::False`
  - `Types::Maybe::Strict::Integer`
  - `Types::Maybe::Strict::Float`
  - `Types::Maybe::Strict::Decimal`
  - `Types::Maybe::Strict::Date`
  - `Types::Maybe::Strict::DateTime`
  - `Types::Maybe::Strict::Time`
  - `Types::Maybe::Strict::Array`
  - `Types::Maybe::Strict::Hash`

* `Maybe` coercible types:
  - `Types::Maybe::Coercible::String`
  - `Types::Maybe::Coercible::Integer`
  - `Types::Maybe::Coercible::Float`
  - `Types::Maybe::Coercible::Decimal`
  - `Types::Maybe::Coercible::Array`
  - `Types::Maybe::Coercible::Hash`

> `Maybe` types are not available by default - they must be loaded using `Dry::Types.load_extensions(:maybe)`. See [Maybe extension](docs::extensions/maybe) for more information.
