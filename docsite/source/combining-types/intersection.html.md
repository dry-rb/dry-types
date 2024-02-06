---
title: Intersection
layout: gem-single
name: dry-types
---

Intersection types are specified using the `&` operator. It combines two
compatible types into a single one with properties from each.

One example is a `Hash` that allows any keys, but requires one of them to be named `id`:

```ruby
Id = Types::Hash.schema(id: Types::Integer)
HashWithId = Id & Types::Hash

Id[{id: 1}]                             # => {:id=>1}
Id[{id: 1, message: 'foo'}]             # => {:id=>1}
Id[{message: 'foo'}]                    # => Dry::Types::MissingKeyError: :id is missing in Hash input

HashWithId[{ message: 'hello' }]        # => Dry::Types::MissingKeyError: :id is missing in Hash input
HashWithId[{ id: 1, message: 'hello' }] # => {:id=>1, :message=>"hello"}
```
