---
title: Hash Schemas
layout: gem-single
name: dry-types
---

It is possible to define a type for a hash with a known set of keys and corresponding value types. Let's say you want to describe a hash containing the name and the age of a user:

```ruby
# using simple kernel coercions
user_hash = Types::Hash.schema(name: Types::String, age: Types::Coercible::Integer)

user_hash[name: 'Jane', age: '21']
# => { name: 'Jane', age: 21 }
# :name left untouched and :age was coerced to Integer
```

If a value doesn't conform to the type, an error is raised:

```ruby
user_hash[name: :Jane, age: '21']
# => Dry::Types::SchemaError: :Jane (Symbol) has invalid type
#    for :name violates constraints (type?(String, :Jane) failed)
```

All keys are required by default:

```ruby
user_hash[name: 'Jane']
# => Dry::Types::MissingKeyError: :age is missing in Hash input
```

Extra keys are omitted by default:

```ruby
user_hash[name: 'Jane', age: '21', city: 'London']
# => { name: 'Jane', age: 21 }
```

### Default values

Default types are **only** evaluated if the corresponding key is missing in the input:

```ruby
user_hash = Types::Hash.schema(
  name: Types::String,
  age: Types::Integer.default(18)
)
user_hash[name: 'Jane']
# => { name: 'Jane', age: 18 }

# nil violates the constraint
user_hash[name: 'Jane', age: nil]
# => Dry::Types::SchemaError: nil (NilClass) has invalid type
#    for :age violates constraints (type?(Integer, nil) failed)
```

In order to evaluate default types on `nil`, wrap your type with a constructor and map `nil` to `Dry::Types::Undefined`:

```ruby
user_hash = Types::Hash.schema(
  name: Types::String,
  age: Types::Integer.
         default(18).
         constructor { |value|
           value.nil? ? Dry::Types::Undefined : value
         }
)

user_hash[name: 'Jane', age: nil]
# => { name: 'Jane', age: 18 }
```

The process of converting types to constructors like that can be automated, see "Type transformations" below.

### Optional keys

By default, all keys are required to present in the input. You can mark a key as optional by adding `?` to its name:

```ruby
user_hash = Types::Hash.schema(name: Types::String, age?: Types::Integer)

user_hash[name: 'Jane']
# => { name: 'Jane' }
```

### Extra keys

All keys not declared in the schema are silently ignored. This behavior can be changed by calling `.strict` on the schema:

```ruby
user_hash = Types::Hash.schema(name: Types::String).strict
user_hash[name: 'Jane', age: 21]
# => Dry::Types::UnknownKeysError: unexpected keys [:age] in Hash input
```

### Transforming input keys

Keys are supposed to be symbols but you can attach a key tranformation to a schema, e.g. for converting strings into symbols:

```ruby
user_hash = Types::Hash.schema(name: Types::String).with_key_transform(&:to_sym)
user_hash['name' => 'Jane']

# => { name: 'Jane' }
```

### Inheritance

Hash schemas can be inherited in a sense you can define a new schema based on an existing one. Declared keys will be merged, key and type transformations will be preserved. The `strict` option is also passed to the new schema if present.

```ruby
# Building an empty base schema
StrictSymbolizingHash = Types::Hash.schema({}).strict.with_key_transform(&:to_sym)

user_hash = StrictSymbolizingHash.schema(
  name: Types::String
)

user_hash['name' => 'Jane']
# => { name: 'Jane' }

user_hash['name' => 'Jane', 'city' => 'London']
# => Dry::Types::UnknownKeysError: unexpected keys [:city] in Hash input
```

### Merging schemas

Similar to inheritance, two schemas can be merged.
The resulting schema will have the sum of both sets
of attributes.

```ruby
user_hash = Types::Hash.schema(
  name: Types::String
)

address_hash = Types::Hash.schema(
  address: Types::String
)

user_with_address_schema = user_hash.merge(address_hash)

user_with_address_schema['name' => 'Jane', 'address' => 'C/ Foo']
# => { name: 'Jane', address: 'C/ Foo' }
```

Keep in mind that key transformations from the caller schema are preserved,
while each attribute keeps the type transformations from its original hash.

### Transforming types

A schema can transform types with a block. For example, the following code makes all keys optional:

```ruby
user_hash = Types::Hash.with_type_transform { |type| type.required(false) }.schema(
  name: Types::String,
  age: Types::Integer
)

user_hash[name: 'Jane']
# => { name: 'Jane' }
user_hash[{}]
# => {}
```

Type transformations work perfectly with inheritance, you don't have to define same rules more than once:

```ruby
SymbolizeAndOptionalSchema = Types::Hash
  .schema({})
  .with_key_transform(&:to_sym)
  .with_type_transform { |type| type.required(false) }

user_hash = SymbolizeAndOptionalSchema.schema(
  name: Types::String,
  age: Types::Integer
)

user_hash['name' => 'Jane']
```

You can check key name by calling `.name` on the type argument:

```ruby
Types::Hash.with_type_transform do |key|
  if key.name.to_s.end_with?('_at')
    key.constructor { |v| Time.iso8601(v) }
  else
    key
  end
end
```
