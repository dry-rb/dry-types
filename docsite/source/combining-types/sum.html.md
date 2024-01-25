---
title: Sum
layout: gem-single
name: dry-types
---

You can specify sum types using `|` operator, it is an explicit way of defining what the valid types of a value are.

For example `dry-types` defines the `Bool` type which is a sum consisting of the `True` and `False` types, expressed as `Types::True | Types::False`.

Another common case is defining that something can be either `nil` or something else:

``` ruby
nil_or_string = Types::Nil | Types::String

nil_or_string[nil] # => nil
nil_or_string["hello"] # => "hello"

nil_or_string[123] # raises Dry::Types::ConstraintError
```
