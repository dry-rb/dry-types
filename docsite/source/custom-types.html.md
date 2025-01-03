---
title: Custom Types
layout: gem-single
name: dry-types
---

There are a bunch of helpers for building your own types based on existing classes and values. These helpers are automatically defined if you're imported types in a module.

### `Types.Instance`

`Types.Instance` builds a type that checks if a value has the given class.

```ruby
range_type = Types.Instance(Range)
range_type[1..2] # => 1..2
```

### `Types.Value`

`Types.Value` builds a type that checks a value for equality (using `==`).

```ruby
valid = Types.Value('valid')
valid['valid'] # => 'valid'
valid['invalid']
# => Dry::Types::ConstraintError: "invalid" violates constraints (eql?("valid", "invalid") failed)
```

### `Types.Constant`

`Types.Constant` builds a type that checks a value for identity (using `equal?`).

```ruby
valid = Types.Constant(:valid)
valid[:valid] # => :valid
valid[:invalid]
# => Dry::Types::ConstraintError: :invalid violates constraints (is?(:valid, :invalid) failed)
```

### `Types.Constructor`

`Types.Constructor` builds a new constructor type for the given class. By default uses the `new` method as a constructor.

```ruby
class User
  def initialize(attributes)
    @attributes = attributes
  end

  def name = @attributes.fetch(:name)
end

user_type = Types.Constructor(User)

# It is equivalent to User.new(name: 'John')
user_type[name: 'John']

# Using a method User.build
user_type = Types.Constructor(User, User.method(:build))

# Using a block
user_type = Types.Constructor(User) { |values| User.new(values) }
```

### `Types.Nominal`

`Types.Nominal` wraps the given class with a simple definition without any behavior attached.

```ruby
int = Types.Nominal(Integer)
int[1] # => 1

# The type doesn't have any checks
int['one'] # => 'one'
```

### `Types.Hash`

`Types.Hash` builds a new hash schema.

```ruby
# In the full form
Types::Hash.schema(name: Types::String, age: Types::Coercible::Integer)

# Using Types.Hash()
Types.Hash(name: Types::String, age: Types::Coercible::Integer)
```

### `Types.Array`

`Types.Array` is a shortcut for `Types::Array.of`

```ruby
ListOfStrings = Types.Array(Types::String)
```

### `Types.Interface`

`Types.Interface` builds a type that checks a value responds to given methods.

```ruby
Callable = Types.Interface(:call)
Contact = Types.Interface(:name, :phone)
```
