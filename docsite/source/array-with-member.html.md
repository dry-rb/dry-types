---
title: Array With Member
layout: gem-single
name: dry-types
---

The built-in array type supports defining the member's type:

``` ruby
PostStatuses = Types::Strict::Array.of(Types::Coercible::String)

PostStatuses[[:foo, :bar]] # ["foo", "bar"]
```
