---
title: Range With Member
layout: gem-single
name: dry-types
---

The built-in range type supports defining the member's type:

``` ruby
IntegerRange = Types::Range.of(Types::Coercible::Integer)

IntegerRange[1.0..2.0] # 1..2
```
