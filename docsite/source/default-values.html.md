---
title: Default Values
layout: gem-single
name: dry-types
---

A type with a default value will return the configured value when the input is not defined:

``` ruby
PostStatus = Types::String.default('draft')

PostStatus[] # "draft"
PostStatus["published"] # "published"
PostStatus[true] # raises ConstraintError
```

It works with a callable value:

``` ruby
CallableDateTime = Types::DateTime.default { DateTime.now }

CallableDateTime[]
# => #<DateTime: 2017-05-06T00:43:06+03:00 ((2457879j,78186s,649279000n),+10800s,2299161j)>
CallableDateTime[]
# => #<DateTime: 2017-05-06T00:43:07+03:00 ((2457879j,78187s,635494000n),+10800s,2299161j)>
```

`Dry::Types::Undefined` can be passed explicitly as a missing value:

```ruby
PostStatus = Types::String.default('draft')

PostStatus[Dry::Types::Undefined] # "draft"
```

It also receives the type constructor as an argument:

```ruby
CallableDateTime = Types::DateTime.constructor(&:to_datetime).default { |type| type[Time.now] }

CallableDateTime[Time.now]
# => #<DateTime: 2017-05-06T01:13:06+03:00 ((2457879j,79986s,63464000n),+10800s,2299161j)>
CallableDateTime[Date.today]
# => #<DateTime: 2017-05-06T00:00:00+00:00 ((2457880j,0s,0n),+0s,2299161j)>
CallableDateTime[]
# => #<DateTime: 2017-05-06T01:13:06+03:00 ((2457879j,79986s,63503000n),+10800s,2299161j)>
```

**Be careful:** types will return the **same instance** of the default value every time. This may cause problems if you mutate the returned value after receiving it:

```ruby
default_0 = PostStatus.()
# => "draft"
default_1 = PostStatus.()
# => "draft"

# Both variables point to the same string:
default_0.object_id == default_1.object_id
# => true

# Mutating the string will change the default value of type:
default_0 << '_mutated'
PostStatus.(nil)
# => "draft_mutated" # not "draft"
```

You can guard against these kind of errors by calling `freeze` when setting the default:

```ruby
PostStatus = Types::Params::String.default('draft'.freeze)
default = PostStatus.()
default << 'attempt to mutate default'
# => RuntimeError: can't modify frozen string

# If you really want to mutate it, call `dup` on it first:
default = default.dup
default << "this time it'll work"
```

**Warning on using with constrained types**: If the value passed to the `.default` block does not match the type constraints, this will not throw an exception, because it is not passed to the constructor and will be used as is.

```ruby
CallableDateTime = Types::DateTime.constructor(&:to_datetime).default { Time.now }

CallableDateTime[Time.now]
# => #<DateTime: 2017-05-06T00:50:09+03:00 ((2457879j,78609s,839588000n),+10800s,2299161j)>
CallableDateTime[Date.today]
# => #<DateTime: 2017-05-06T00:00:00+00:00 ((2457880j,0s,0n),+0s,2299161j)>
CallableDateTime[]
# => 2017-05-06 00:50:15 +0300
```
