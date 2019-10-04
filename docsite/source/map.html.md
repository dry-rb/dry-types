---
title: Map
layout: gem-single
name: dry-types
---

`Map` describes a homogeneous hashmap. This means only types of keys and values are known. You can simply imagine a map input as a list of key-value pairs.

```ruby
int_float_hash = Types::Hash.map(Types::Integer, Types::Float)
int_float_hash[100 => 300.0, 42 => 70.0]
# => {100=>300.0, 42=>70.0}

# Only accepts mappings of integers to floats
int_float_hash[name: 'Jane']
# => Dry::Types::MapError: input key :name is invalid: type?(Integer, :name)
```
