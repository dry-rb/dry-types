---
title: Strict
layout: gem-single
name: dry-types
order: 3
---

All types in the `strict` category are [constrained](/gems/dry-types/constraints) by a type-check that is applied to an input which makes sure that the input is an instance of the primitive:

``` ruby
Types::Strict::Integer[1] # => 1
Types::Strict::Integer['1'] # => raises Dry::Types::ConstraintError
```
