---
title: Type Attributes
layout: gem-single
name: dry-types
---

Types themselves have optional attributes you can apply to get further functionality.

### Append `.optional` to a _Type_ to allow `nil` 

By default, nil values raise an error:

``` ruby
Types.string[nil]
# => raises Dry::Types::ConstraintError
```

Add `.optional` and `nil` values become valid:

```ruby
optional_string = Types.string.optional

optional_string[nil]
# => nil
optional_string['something']
# => "something"
optional_string[123]
# raises Dry::Types::ConstraintError
```

`Types.string.optional` is just syntactic sugar for `Types.nil | Types.string`.

### Handle optional values using Monads

The [dry-monads gem](/gems/dry-monads/) provides another approach to handling optional values by returning a [_Monad_](/gems/dry-monads/) object. This allows you to pass your type to a `Maybe(x)` block that only executes if `x` returns `Some` or `None`.

> NOTE: Requires the [dry-monads gem](/gems/dry-monads/) to be loaded.

1. Load the `:maybe` extension in your application.

    ```ruby
    require 'dry-types'
    
    Dry::Types.load_extensions(:maybe)
    module Types
      include Dry.Types()
    end
    ```
   
2. Append `.maybe` to a _Type_ to return a _Monad_ object  

```ruby
x = Types::Maybe::Strict::Integer[nil]
Maybe(x) { puts(x) }

x = Types::Maybe::Coercible::String[nil]
Maybe(x) { puts(x) }

x = Types::Maybe::Strict::Integer[123]
Maybe(x) { puts(x) }

x = Types::Maybe::Strict::String[123]
Maybe(x) { puts(x) }
```

```ruby
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

maybe_string['something'].fmap(&:upcase).value_or('NOTHING')
# => "SOMETHING"
```
