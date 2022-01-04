---
title: Type Attributes
layout: gem-single
name: dry-types
---

Types themselves have optional attributes you can apply to get further functionality.

### Append `.optional` to a type to allow `nil`

By default, nil values raise an error:

``` ruby
Types = Dry.Types()

Types::Strict::String[nil]
# => raises Dry::Types::ConstraintError
```

Add `.optional` and `nil` values become valid:

```ruby
optional_string = Types::Strict::String.optional

optional_string[nil]
# => nil
optional_string['something']
# => "something"
optional_string[123]
# raises Dry::Types::ConstraintError
```

`Types::String.optional` is just syntactic sugar for `Types::Strict::Nil | Types::Strict::String`.

### Handle optional values using monads

See the [Maybe](docs::extensions/maybe) extension for another approach to handling optional values by returning a [_monad_](/gems/dry-monads/) object.
