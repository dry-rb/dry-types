---
title: Custom Type Builders
layout: gem-single
name: dry-types
---

It is idiomatic to construct new types based on existing.

```ruby
source_type = Dry::Types['integer']
constructor_type = source_type.constructor(Kernel.method(:Integer))
constrained_type = constructor_type.constrained(gteq: 18)
```

This API can be extended with `Dry::Types.define_builder`

```ruby
Dry::Types.define_builder(:or) { |type, value| type.fallback(value) }

source_type = Dry::Types['integer']
type = source_type.or(0)
type.(10) # => 10
type.(:invalid) # => 0
```
