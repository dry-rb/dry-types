[gem]: https://rubygems.org/gems/dry-data
[travis]: https://travis-ci.org/dryrb/dry-data
[gemnasium]: https://gemnasium.com/dryrb/dry-data
[codeclimate]: https://codeclimate.com/github/dryrb/dry-data
[coveralls]: https://coveralls.io/r/dryrb/dry-data
[inchpages]: http://inch-ci.org/github/dryrb/dry-data

# dry-data [![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dryrb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-data.svg)][gem]
[![Build Status](https://travis-ci.org/dryrb/dry-data.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dryrb/dry-data.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dryrb/dry-data/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dryrb/dry-data/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dryrb/dry-data.svg?branch=master)][inchpages]

A simple and extendible type system for Ruby with support for kernel coercions,
form coercions, sum types, constrained types and default-value types.

Used by:

* [dry-validation](https://github.com/dryrb/dry-validation) for params coercions
* [rom-repository](https://github.com/rom-rb/rom-repository) for auto-mapped structs
* [rom](https://github.com/rom-rb/rom)'s adapters for relation schema definitions
* your project...?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dry-data

## Usage

You can use `dry-data` for defining various data types in your application, like
domain entities and value objects or hashes with coercible values used to handle
params.

Built-in types are grouped under 5 categories:

- default: pass-through without any checks
- `strict` - doesn't coerce and checks the input type against the primitive class
- `coercible` - tries to coerce and raises type-error if it failed
- `form` - non-strict coercion types suitable for form params
- `maybe` - accepts either a nil or something else

### Configuring Types Module

In `dry-data` a type is an object with a constructor that knows how to handle
input. On top of that there are high-level types like a sum-type, constrained type,
optional type or default value type.

To acccess all the built-in type objects you can configure `dry-data` with a
namespace module:

``` ruby
module Types
end

Dry::Data.configure do |config|
  config.namespace = Types
end

# after defining your custom types (if you've got any) you can finalize setup
Dry::Data.finalize

# this defines all types under your namespace, in example:
Types::Coercible::String
# => #<Dry::Data::Type:0x007feffb104aa8 @constructor=#<Method: Kernel.String>, @primitive=String>
```

With types accessible as constants you can easily compose more complex types,
like sum-types or constrained types, in hash schemas or structs:

``` ruby
Dry::Data.configure do |config|
  config.namespace = Types
end

Dry::Data.finalize

module Types
  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  Age = Int.constrained(gt: 18)
end

class User < Dry::Data::Struct
  attribute :name, Types::String
  attribute :email, Types::Email
  attribute :age, Types::Age
end
```

### Built-in Type Categories

Assuming you configured types under `Types` module namespace:

Non-coercible:

- `Types::Nil`
- `Types::Symbol`
- `Types::Class`
- `Types::True`
- `Types::False`
- `Types::Date`
- `Types::DateTime`
- `Types::Time`

Coercible types using kernel coercion methods:

- `Types::Coercible.String`
- `Types::Coercible.Int`
- `Types::Coercible.Float`
- `Types::Coercible.Decimal`
- `Types::Coercible.Array`
- `Types::Coercible.Hash`

Optional strict types:

- `Types::Maybe.Strict.String`
- `Types::Maybe.Strict.Int`
- `Types::Maybe.Strict.Float`
- `Types::Maybe.Strict.Decimal`
- `Types::Maybe.Strict.Array`
- `Types::Maybe.Strict.Hash`

Optional coercible types:

- `Types::Maybe.Coercible.String`
- `Types::Maybe.Coercible.Int`
- `Types::Maybe.Coercible.Float`
- `Types::Maybe.Coercible.Decimal`
- `Types::Maybe.Coercible.Array`
- `Types::Maybe.Coercible.Hash`

Coercible types suitable for form param processing:

- `Types::Form.Nil`
- `Types::Form.Date`
- `Types::Form.DateTime`
- `Types::Form.Time`
- `Types::Form.True`
- `Types::Form.False`
- `Types::Form.Bool`
- `Types::Form.Int`
- `Types::Form.Float`
- `Types::Form.Decimal`

### Strict vs Coercible Types

``` ruby
Types::Strict::Int[1] # => 1
Types::Strict::Int['1'] # => raises TypeError

# coercible type-check group
Types::Coercible::String[:foo] # => 'foo'
Types::Coercible::Array[:foo] # => [:foo]

# form group
Types::Form::Date['2015-11-29'] # => #<Date: 2015-11-29 ((2457356j,0s,0n),+0s,2299161j)>
```

### Optional types

All built-in types have their optional versions too, you can access them under
`"maybe.strict"` and `"maybe.coercible"` categories:

``` ruby
maybe_int = Dry::Data["maybe.strict.int"]

maybe_int[nil] # None
maybe_int[123] # Some(123)

maybe_coercible_float = Dry::Data["maybe.coercible.float"]

maybe_coercible_float[nil] # None
maybe_coercible_float['12.3'] # Some(12.3)
```

You can define your own optional types too:

``` ruby
maybe_string = Dry::Data["string"].optional

maybe_string[nil]
# => None

maybe_string[nil].fmap(&:upcase)
# => None

maybe_string['something']
# => Some('something')

maybe_string['something'].fmap(&:upcase)
# => Some('SOMETHING')

maybe_string['something'].fmap(&:upcase).value
# => "SOMETHING"
```

### Sum-types

You can specify sum types using `|` operator, it is an explicit way of defining
what are the valid types of a value.

In example `dry-data` defines `bool` type which is a sum-type consisting of `true`
and `false` types which is expressed as `Dry::Data['true'] | Dry::Data['false']`
(and it has its strict version, too).

Another common case is defining that something can be either `nil` or something else:

``` ruby
nil_or_string = Dry::Data['strict.nil'] | Dry::Data['strict.string']

nil_or_string[nil] # => nil
nil_or_string["hello"] # => "hello"
```

### Constrained Types

You can create constrained types that will use validation rules to check if the
input is not violating any of the configured contraints. You can treat it as
a lower level guarantee that you're not instantiating objects that are broken.

All types support constraints API, but not all constraints are suitable for a
particular primitive, it's up to you to set up constraints that make sense.

Under the hood it uses [`dry-logic`](https://github.com/dryrb/dry-logic)
and all of its predicates are supported.

``` ruby
string = Dry::Data["strict.string"].constrained(min_size: 3)

string['foo']
# => "foo"

string['fo']
# => Dry::Data::ConstraintError: "fo" violates constraints

email = Dry::Data['strict.string'].constrained(
  format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
)

email["jane@doe.org"]
# => "jane@doe.org"

email["jane"]
# => Dry::Data::ConstraintError: "fo" violates constraints
```

### Defining Enums

In many cases you may want to define an enum. For example in a blog application
a post may have a finite list of statuses. Apart from accessing the current status
value it is useful to have all possible values accessible too. Furthermore an
enum is a `int => value` map, so you can store integers somewhere and have them
mapped to enum values conveniently.

You can define enums for every type but it probably only makes sense for `string`:

``` ruby
# assuming we have types loaded into `Types` namespace
# we can easily define an enum for our post struct
class Post < Dry::Data::Struct
  Statuses = Types::Strict::String.enum('draft', 'published', 'archived')

  attribute :title, Types::Strict::String
  attribute :body, Types::Strict::String
  attribute :status, Statuses
end

# enum values are frozen, let's be paranoid, doesn't hurt and have potential to
# eliminate silly bugs
Post::Statuses.values.frozen? # => true
Post::Statuses.values.all?(&:frozen?) # => true

# you can access values using indices or actual values
Post::Statuses[0] # => "draft"
Post::Statuses['draft'] # => "draft"

# it'll raise if something silly was passed in
Post::Statuses['something silly']
# => Dry::Data::ConstraintError: "something silly" violates constraints

# nil is considered as something silly too
Post::Statuses[nil]
# => Dry::Data::ConstraintError: nil violates constraints
```

### Defining a hash with explicit schema

The built-in hash type has constructors that you can use to define hashes with
explicit schemas and coercible values using the built-in types.

### Hash Schema

``` ruby
# using simple kernel coercions
hash = Dry::Data['hash'].schema(name: 'string', age: 'coercible.int')

hash[name: 'Jane', age: '21']
# => { :name => "Jane", :age => 21 }

# using form param coercions
hash = Dry::Data['hash'].schema(name: 'string', birthdate: 'form.date')

hash[name: 'Jane', birthdate: '1994-11-11']
# => { :name => "Jane", :birthdate => #<Date: 1994-11-11 ((2449668j,0s,0n),+0s,2299161j)> }
```

### Strict Hash

Strict hash will raise errors when keys are missing or value types are incorrect.

``` ruby
hash = Dry::Data['hash'].strict(name: 'string', age: 'coercible.int')

hash[email: 'jane@doe.org', name: 'Jane', age: 21]
# => Dry::Data::SchemaKeyError: :email is missing in Hash input
```

### Symbolized Hash

Symbolized hash will turn string key names into symbols

``` ruby
hash = Dry::Data['hash'].symbolized(name: 'string', age: 'coercible.int')

hash['name' => 'Jane', 'age' => '21']
# => { :name => "Jane", :age => 21 }
```

### Defining a struct

You can define struct objects which will have attribute readers for specified
attributes using a simple dsl:

``` ruby
class User < Dry::Data::Struct
  attribute :name, "maybe.coercible.string"
  attribute :age, "coercible.int"
end

# becomes available like any other type
user_type = Dry::Data["user"]

user = user_type[name: nil, age: '21']

user.name # None
user.age # 21

user = user_type[name: 'Jane', age: '21']

user.name # => Some("Jane")
user.age # => 21
```

## Status and Roadmap

This library is in an early stage of development but you are encouraged to try it
out and provide feedback.

For planned features check out [the issues](https://github.com/dryrb/dry-data/labels/feature).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dryrb/dry-data.
