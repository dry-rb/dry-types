---
title: Enum
layout: gem-single
name: dry-types
---

In many cases you may want to define an enum. For example, in a blog application a post may have a finite list of statuses. Apart from accessing the current status value, it is useful to have all possible values accessible too. Furthermore, an enum can be a map from, e.g., strings to integers. This is useful for mapping externally-provided integer values to human-readable strings without explicit conversions, see examples.

``` ruby
require 'dry-types'
require 'dry-struct'

module Types
  include Dry.Types()
end

class Post < Dry::Struct
  Statuses = Types::String.enum('draft', 'published', 'archived')

  attribute :title, Types::String
  attribute :body, Types::String
  attribute :status, Statuses
end

# enum values are frozen, let's be paranoid, doesn't hurt and have potential to
# eliminate silly bugs
Post::Statuses.values.frozen? # => true
Post::Statuses.values.all?(&:frozen?) # => true

Post::Statuses['draft'] # => "draft"

# it'll raise if something silly was passed in
Post::Statuses['something silly']
# => Dry::Types::ConstraintError: "something silly" violates constraints

# nil is considered as something silly too
Post::Statuses[nil]
# => Dry::Types::ConstraintError: nil violates constraints
```

Note that if you want to define an enum type with a default, you must call `.default` *before* calling `.enum`, not the other way around:

```ruby
# this is the correct usage:
Dry::Types::String.default('red').enum('blue', 'green', 'red')

# this will raise an error:
Dry::Types::String.enum('blue', 'green', 'red').default('red')
```

### Mappings

A classic example is mapping integers coming from somewhere (API/database/etc) to something more understandable:

```ruby
class Cell < Dry::Struct
  attribute :state, Types::String.enum('locked' => 0, 'open' => 1)
end


Cell.new(state: 'locked')
# => #<Cell state="locked">

# Integers are accepted too
Cell.new(state: 0)
# => #<Cell state="locked">
Cell.new(state: 1)
# => #<Cell state="open">
```
