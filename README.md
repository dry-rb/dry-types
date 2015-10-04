# Dry::Data <a href="https://gitter.im/dryrb/chat" target="_blank">![Join the chat at https://gitter.im/dryrb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/dry-data" target="_blank">![Gem Version](https://badge.fury.io/rb/dry-data.svg)</a>
<a href="https://travis-ci.org/dryrb/dry-data" target="_blank">![Build Status](https://travis-ci.org/dryrb/dry-data.svg?branch=master)</a>
<a href="https://gemnasium.com/dryrb/dry-data" target="_blank">![Dependency Status](https://gemnasium.com/dryrb/dry-data.svg)</a>
<a href="https://codeclimate.com/github/dryrb/dry-data" target="_blank">![Code Climate](https://codeclimate.com/github/dryrb/dry-data/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/dryrb/dry-data" target="_blank">![Documentation Status](http://inch-ci.org/github/dryrb/dry-data.svg?branch=master&style=flat)</a>

A simple type-system for Ruby respecting ruby's built-in coercion mechanisms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dry-data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dry-data

## Why?

Unlike seemingly similar libraries like virtus, attrio, fast_attrs, attribs etc.
`Dry::Data` provides you an interface to explicitly specify data types you want
to use in your application domain which gives you type-safety and *simple* coercion
mechanism using built-in coercion methods on the kernel.

Main difference is that `Dry::Data` is not designed to handle all kinds of complex
coercions that are typically required when dealing with, let's say, form params
in a web application. Its primary focus is to allow you to specify the exact shape
of the custom application data types to avoid silly bugs that are often hard to debug
(`NoMethodError: undefined method `size' for nil:NilClass` anyone?).

## Usage

Primary usage of this library is defining domain data types that your application
will work with. The interface consists of lower-level type definitions and a higher-level
virtus-like interface for defining structs.


### Accessing built-in types

Coercible types using kernel coercion methods:

- `string`
- `int`
- `float`
- `decimal`
- `array`
- `hash`

Non-coercible:

- `nil`
- `true`
- `false`
- `date`
- `date_time`
- `time`

More types will be added soon.

Types are grouped under 4 categories:

- default: pass-through without any checks
- `strict` - doesn't coerce and checks the input type against the primitive class
- `coercible` - tries to coerce and raises type-error if it failed
- `maybe` - accepts either a nil or something else

``` ruby
# default passthrough category
float = Dry::Data["float"]

float[3.2] # => 3.2
float["3.2"] # "3.2"

# strict type-check category
int = Dry::Data["strict.int"]

int[1] # => 1
int['1'] # => raises TypeError

# coercible type-check group
string = Dry::Data["coercible.string"]
array = Dry::Data["coercible.array"]

string[:foo] # => 'foo'
array[:foo] # => [:foo]
```

### Optional types

All built-in types have their optional versions too, you can access them under
`"maybe.strict"` and `"maybe.coercible"` categories:

``` ruby
maybe_int = Dry::Data["maybe.strict.int"]

maybe_int[nil] # None
maybe_int[123] # Some(123)

maybe_coercible_float = Dry::Data["maybe.coercible.float"]

maybe_int[nil] # None
maybe_int['12.3'] # Some(12.3)
```

You can define your own optional types too:

``` ruby
maybe_string = Dry::Data["nil"] | Dry::Data["string"]

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

### Defining a struct

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

## WIP

This is early alpha with a rough plan to:

* Add constrained types (ie a string with a strict length, a number with a strict range etc.)
* Benchmark against other libs and make sure it's fast enough

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dryrb/dry-data.
