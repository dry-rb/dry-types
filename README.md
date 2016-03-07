[gem]: https://rubygems.org/gems/dry-types
[travis]: https://travis-ci.org/dryrb/dry-types
[gemnasium]: https://gemnasium.com/dryrb/dry-types
[codeclimate]: https://codeclimate.com/github/dryrb/dry-types
[coveralls]: https://coveralls.io/r/dryrb/dry-types
[inchpages]: http://inch-ci.org/github/dryrb/dry-types

# dry-types [![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dryrb/chat)

[![Gem Version](https://badge.fury.io/rb/dry-types.svg)][gem]
[![Build Status](https://travis-ci.org/dryrb/dry-types.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/dryrb/dry-types.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/dryrb/dry-types/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/dryrb/dry-types/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/dryrb/dry-types.svg?branch=master)][inchpages]

A simple and extendible type system for Ruby with support for kernel coercions,
form coercions, sum types, constrained types and default-value types.

Used by:

* [dry-validation](https://github.com/dryrb/dry-validation) for params coercions
* [rom-repository](https://github.com/rom-rb/rom-repository) for auto-mapped structs
* [rom](https://github.com/rom-rb/rom)'s adapters for relation schema definitions
* your project...?

Articles:

* ["Invalid Object Is An Anti-Pattern"](http://solnic.eu/2015/12/28/invalid-object-is-an-anti-pattern.html)

## dry-types vs virtus

[Virtus](https://github.com/solnic/virtus) has been a successful library, unfortunately
it is "only" a by-product of an ActiveRecord ORM which carries many issues typical
to ActiveRecord-like features that we all know from Rails, especially when it
comes to very complicated coercion logic, mixing unrelated concerns, polluting
application layer with concerns that should be handled at the bounderies etc.

`dry-types` has been created to become a better tool that solves *similar* (but
not identical!) problems related to type-safety and coercions. It is a superior
solution because:

* Types are [categorized](#built-in-type-categories), which is especially important for coercions
* Types are objects and they are easily reusable
* Has [structs](#structs) and [values](#values) with *a simple DSL*
* Has [constrained types](#constrained-types)
* Has [optional types](#optional-types)
* Has [defaults](#defaults)
* Has [sum-types](#sum-types)
* Has [enums](#enums)
* Has [hash type with type schemas](#hashes)
* Has [array type with member type](#arrays)
* Suitable for many use-cases while remaining simple, in example:
  * Params coercions
  * Domain "models"
  * Defining various domain-specific, shared information using enums or values
  * Annotating objects
  * and more...
* There's no const-missing magic and complicated const lookups like in Virtus
* AND is roughly 10-12x faster than Virtus

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-types'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dry-types

## Usage

You can use `dry-types` for defining various types types in your application, like
domain entities and value objects or hashes with coercible values used to handle
params.

Built-in types are grouped under 5 categories:

- default: pass-through without any checks
- `strict` - doesn't coerce and checks the input type against the primitive class
- `coercible` - tries to coerce and raises type-error if it failed
- `form` - non-strict coercion types suitable for form params
- `maybe` - accepts either a nil or something else

### Configuring Types Module

In `dry-types` a type is an object with a constructor that knows how to handle
input. On top of that there are high-level types like a sum-type, constrained type,
optional type or default value type.

To access all the built-in type objects you can include `dry-types` module inside
your own namespace:

``` ruby
module Types
  include Dry::Types.module
end

# this defines all types under your namespace, in example:
Types::Coercible::String
# => #<Dry::Types::Constructor type=#<Dry::Types::Definition primitive=String options={}>>
```

With types accessible as constants you can easily compose more complex types,
like sum-types or constrained types, in hash schemas or structs:

``` ruby
module Types
  include Dry::Types.module

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  Age = Int.constrained(gt: 18)
end

class User < Dry::Types::Struct
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

- `Types::Coercible::String`
- `Types::Coercible::Int`
- `Types::Coercible::Float`
- `Types::Coercible::Decimal`
- `Types::Coercible::Array`
- `Types::Coercible::Hash`

Optional strict types:

- `Types::Maybe::Strict::String`
- `Types::Maybe::Strict::Int`
- `Types::Maybe::Strict::Float`
- `Types::Maybe::Strict::Decimal`
- `Types::Maybe::Strict::Array`
- `Types::Maybe::Strict::Hash`

Optional coercible types:

- `Types::Maybe::Coercible::String`
- `Types::Maybe::Coercible::Int`
- `Types::Maybe::Coercible::Float`
- `Types::Maybe::Coercible::Decimal`
- `Types::Maybe::Coercible::Array`
- `Types::Maybe::Coercible::Hash`

Coercible types suitable for form param processing:

- `Types::Form::Nil`
- `Types::Form::Date`
- `Types::Form::DateTime`
- `Types::Form::Time`
- `Types::Form::True`
- `Types::Form::False`
- `Types::Form::Bool`
- `Types::Form::Int`
- `Types::Form::Float`
- `Types::Form::Decimal`

### Strict vs Coercible Types

``` ruby
Types::Strict::Int[1] # => 1
Types::Strict::Int['1'] # => raises Dry::Types::ConstraintError

# coercible type-check group
Types::Coercible::String[:foo] # => 'foo'
Types::Coercible::Array[:foo] # => [:foo]

# form group
Types::Form::Date['2015-11-29'] # => #<Date: 2015-11-29 ((2457356j,0s,0n),+0s,2299161j)>
```

### Optional Types

All built-in types have their optional versions too, you can access them under
`"Types::Maybe::Strict"` and `"Maybe::Coercible"` categories:

``` ruby
Types::Maybe::Int[nil] # None
Types::Maybe::Int[123] # Some(123)

Types::Maybe::Coercible::Float[nil] # None
Types::Maybe::Coercible::Float['12.3'] # Some(12.3)
```

You can define your own optional types too:

``` ruby
maybe_string = Types::Strict::String.optional

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

### Defaults

A type with a default value will return the configured value when the input is `nil`:

``` ruby
PostStatus = Types::Strict::String.default('draft')

PostStatus[nil] # "draft"
PostStatus["published"] # "published"
PostStatus[true] # raises ConstraintError
```

### Sum-types

You can specify sum types using `|` operator, it is an explicit way of defining
what are the valid types of a value.

In example `dry-types` defines `bool` type which is a sum-type consisting of `true`
and `false` types which is expressed as `Types::True | Types::False`
(and it has its strict version, too).

Another common case is defining that something can be either `nil` or something else:

``` ruby
nil_or_string = Types::Nil | Types::Strict::String

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
string = Types::Strict::String.constrained(min_size: 3)

string['foo']
# => "foo"

string['fo']
# => Dry::Types::ConstraintError: "fo" violates constraints

email = Types::Strict::String.constrained(
  format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
)

email["jane@doe.org"]
# => "jane@doe.org"

email["jane"]
# => Dry::Types::ConstraintError: "fo" violates constraints
```

### Enums

In many cases you may want to define an enum. For example in a blog application
a post may have a finite list of statuses. Apart from accessing the current status
value it is useful to have all possible values accessible too. Furthermore an
enum is a `int => value` map, so you can store integers somewhere and have them
mapped to enum values conveniently.

``` ruby
# assuming we have types loaded into `Types` namespace
# we can easily define an enum for our post struct
class Post < Dry::Types::Struct
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
# => Dry::Types::ConstraintError: "something silly" violates constraints

# nil is considered as something silly too
Post::Statuses[nil]
# => Dry::Types::ConstraintError: nil violates constraints
```

### Hashes

The built-in hash type has constructors that you can use to define hashes with
explicit schemas and coercible values using the built-in types.

#### Hash Schema

``` ruby
# using simple kernel coercions
hash = Types::Hash.schema(name: Types::String, age: Types::Coercible::Int)

hash[name: 'Jane', age: '21']
# => { :name => "Jane", :age => 21 }

# using form param coercions
hash = Types::Hash.schema(name: Types::String, birthdate: Form::Date)

hash[name: 'Jane', birthdate: '1994-11-11']
# => { :name => "Jane", :birthdate => #<Date: 1994-11-11 ((2449668j,0s,0n),+0s,2299161j)> }
```

#### Strict Schema

Strict hash will raise errors when keys are missing or value types are incorrect.

``` ruby
hash = Types::Hash.strict(name: 'string', age: 'coercible.int')

hash[email: 'jane@doe.org', name: 'Jane', age: 21]
# => Dry::Types::SchemaKeyError: :email is missing in Hash input
```

#### Symbolized Schema

Symbolized hash will turn string key names into symbols

``` ruby
hash = Types::Hash.symbolized(name: Types::String, age: Types::Coercible::Int)

hash['name' => 'Jane', 'age' => '21']
# => { :name => "Jane", :age => 21 }
```

### Arrays

The built-in array type supports defining member type:

``` ruby
PostStatuses = Types::Strict::Array.member(Types::Coercible::String)

PostStatuses[[:foo, :bar]] # ["foo", "bar"]
```

### Structs

You can define struct objects which will have readers for specified attributes
using a simple dsl:

``` ruby
class User < Dry::Types::Struct
  attribute :name, Types::Maybe::Coercible::String
  attribute :age, Types::Coercible::Int
end

user = User.new(name: nil, age: '21')

user.name # None
user.age # 21

user = User(name: 'Jane', age: '21')

user.name # => Some("Jane")
user.age # => 21
```

### Values

You can define value objects which will behave like structs and have equality
methods too:

``` ruby
class Location < Dry::Types::Value
  attribute :lat, Types::Strict::Float
  attribute :lat, Types::Strict::Float
end

loc1 = Location.new(lat: 1.23, lng: 4.56)
loc2 = Location.new(lat: 1.23, lng: 4.56)

loc1 == loc2
# true
```

## Rails

If you're using Rails then you want to install [dry-types-rails](https://github.com/jeromegn/dry-types-rails) which makes it work in development mode.

## Status and Roadmap

This library is in an early stage of development but you are encouraged to try it
out and provide feedback.

For planned features check out [the issues](https://github.com/dryrb/dry-types/labels/feature).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dryrb/dry-types.
