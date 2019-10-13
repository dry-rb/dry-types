---
title: Optional Values
layout: gem-single
name: dry-types
---

### Optional values

Use the `.optional` method to get a type that has all the same features but also accepts `nil`:

``` ruby
Types::Strict::String[nil]
# => raises Dry::Types::ConstraintError

optional_string = Types::Strict::String.optional

optional_string[nil]
# => nil

optional_string['something']
# => "something"

optional_string[123]
# raises Dry::Types::ConstraintError
```

Under the hood this creates a [sum type](docs::sum).  `Types::String.optional` is just syntactic sugar for `Types::Strict::Nil | Types::Strict::String`.

### Maybe values

For more advanced usage, use types under the `Maybe` namespace to get optional types that return an instance of `Dry::Monads::Maybe::Some` from [dry-monads](/gems/dry-monads).

This functionality is not available by default - it must be loaded using `Dry::Types.load_extensions(:maybe)` and you need to add [`dry-monads`](/gems/dry-monads) to your Gemfile:

``` ruby
require 'dry-types'

Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

Types::Maybe::Strict::Integer[nil] # None
Types::Maybe::Strict::Integer[123] # Some(123)

Types::Maybe::Coercible::Float[nil] # None
Types::Maybe::Coercible::Float['12.3'] # Some(12.3)

# 'Maybe' types can also accessed by calling '.maybe' on a regular type:
Types::Strict::Integer.maybe # equivalent to Types::Maybe::Strict::Integer
```

You can define your own optional types:

``` ruby
maybe_string = Types::Strict::String.maybe

maybe_string[nil]
# => None

maybe_string[nil].fmap(&:upcase)
# => None

maybe_string['something']
# => Some('something')

maybe_string['something'].fmap(&:upcase)
# => Some('SOMETHING')

maybe_string['something'].fmap(&:upcase).value
# => "SOMETHING"
```
