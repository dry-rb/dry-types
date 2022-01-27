---
title: Maybe
layout: gem-single
name: dry-types
---

The [dry-monads gem](/gems/dry-monads/) provides an approach to handling optional values by returning a [`Maybe`](/gems/dry-monads/) object from operations that can return `nil`.

`dry-types` has an extension that can return `Maybe`s from calls to types. That is, it wraps the return result in either:
- a `Some` object (with the resulting value)
- a `None` object (when the value would be `nil`)


> **NOTE**: You must `require 'dry-monads'`, and include `Dry::Monads[:maybe]`

1. Load `dry-monads` with `Maybe` and the `dry-types` `:maybe` extension in your application.

```ruby
require 'dry-monads'
include Dry::Monads[:maybe] # This should be inside your class
require 'dry-types'

Dry::Types.load_extensions(:maybe)
Types = Dry.Types()
```

2. Append `.maybe` to a `Type` to return a `Maybe` object

```ruby
Types::Strict::Integer.maybe[nil]     # => None
Types::Strict::Integer.maybe[123]     # => Some(123)

Types::Coercible::String.maybe[nil]   # => None
Types::Coercible::String.maybe[123]   # => Some("123")

Types::Coercible::Float.maybe[nil]    # => None
Types::Coercible::Float.maybe['12.3'] # => Some(12.3)

Types::Strict::String.maybe[123]      # => raises Dry::Types::ConstraintError
Types::Strict::Integer.maybe["foo"]   # => raises Dry::Types::ConstraintError

```

If you want to capture the errors (e.g. to return messages) instead of raising them, you may want to use the [`:monads` extension](docs::extensions/monads) instead, which returns a `Result`.

Or, if you prefer, instead of calling `.maybe` you can use the `Maybe::` namespaced types instead.

The following examples are identical to the ones above:

```ruby
Types::Maybe::Strict::Integer[nil]     # => None
Types::Maybe::Strict::Integer[123]     # => Some(123)

Types::Maybe::Coercible::String[nil]   # => None
Types::Maybe::Coercible::String[123]   # => Some("123")

Types::Maybe::Coercible::Float[nil]    # => None
Types::Maybe::Coercible::Float['12.3'] # => Some(12.3)

Types::Maybe::Strict::String[123]      # => raises Dry::Types::ConstraintError
Types::Maybe::Strict::Integer["foo"]   # => raises Dry::Types::ConstraintError
```

### Mapping methods on `Maybe`
Since these are `dry-monads` `Maybe` objects, you can `#fmap` methods to them: applying the method to the value when the value is `Some` (and keeping the `None` when the value is `None`).

You can `#fmap` these, and then use `#value_or` to return the underlying value out of a `Some` or return a default when the value is `None`.

``` ruby
maybe_string = Types::Strict::String.maybe
maybe_string[nil]                 # => None
maybe_string[nil].fmap(&:upcase)  # => None
maybe_string['something']                                    # => Some('something')
maybe_string['something'].fmap(&:upcase)                     # => Some('SOMETHING')
maybe_string['something'].fmap(&:upcase).value_or('NOTHING') # => "SOMETHING"
```
