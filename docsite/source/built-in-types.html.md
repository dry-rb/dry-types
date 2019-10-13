---
title: Built-in Types
layout: gem-single
name: dry-types
---

Built-in types are grouped under 6 categories:

- `definition` - base type definitions with primitive class and options
- `strict` - constrained types with a primitive type check applied to input
- `coercible` - types with constructors using kernel coercions
- `params` - types with constructors performing non-strict coercions specific to HTTP params
- `json` - types with constructors performing non-strict coercions specific to JSON
- `maybe` - types accepting either nil or a specific primitive type

### Categories

Assuming you included types in a module called `Types`:

* Base definitions:
  - `Types::Any`
  - `Types::Nil`
  - `Types::Symbol`
  - `Types::Class`
  - `Types::True`
  - `Types::False`
  - `Types::Bool`
  - `Types::Integer`
  - `Types::Float`
  - `Types::Decimal`
  - `Types::String`
  - `Types::Date`
  - `Types::DateTime`
  - `Types::Time`
  - `Types::Array`
  - `Types::Hash`

* `Strict` types will raise an error if passed a value of the wrong type:
  - `Types::Strict::Nil`
  - `Types::Strict::Symbol`
  - `Types::Strict::Class`
  - `Types::Strict::True`
  - `Types::Strict::False`
  - `Types::Strict::Bool`
  - `Types::Strict::Integer`
  - `Types::Strict::Float`
  - `Types::Strict::Decimal`
  - `Types::Strict::String`
  - `Types::Strict::Date`
  - `Types::Strict::DateTime`
  - `Types::Strict::Time`
  - `Types::Strict::Array`
  - `Types::Strict::Hash`

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

> `Maybe` types are not available by default - they must be loaded using `Dry::Types.load_extensions(:maybe)`. See [Optional Values](docs::optional-values) for more information.
