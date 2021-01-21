---
title: Fallbacks
layout: gem-single
name: dry-types
---

Fallback value will be returned when invalid input is provided:

```ruby
type = Dry::Types['integer'].fallback(100)

type.(99) # => 99
type.('99') # => 100
type.(:invalid) # => 100
```

Block syntax:

```ruby
cnt = 0
type = Dry::Types['integer'].fallback { cnt += 1 }

type.(99) # => 99
type.('99') # => 1
type.(:invalid) # => 2
```

Fallbacks are different from default values because the latter are triggered on _missing_ input rather than invalid. They can be combined:

```ruby
schema = Dry::Types['hash'].schema(
  size: Dry::Types['integer'].fallback(50).default(100)
)
schema.({}) # => { size: 100 }
schema.({ size: 'invalid' }) # => { size: 50 }
```
