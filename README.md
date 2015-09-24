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
mechanism using simple procs for coercion.

Main difference is that `Dry::Data` is not designed to handle all kinds of complex
coercions that are typically required when dealing with, let's say, form params
in a web application. Its primary focus is to allow you to specify the exact shape
of the custom application data types to avoid silly bugs that are often hard to debug
(`NoMethodError: undefined method `size' for nil:NilClass` anyone?).

## Usage

Primary usage of this library is defining domain data types that your application
will work with. The interface consists of lower-level type definitions and a higher-level
virtus-like interface for defining structs.


### Using built-in types

For now the usage is very simple, more features will be built upon this interface:

``` ruby
Dry::Data[:string][:foo] # => 'foo'
Dry::Data[:array][:foo] # => [:foo]
```

### Defining a struct

``` ruby
class User
  include Dry::Data::Struct

  attributes name: :string, age: :int
end

# you can register this type with the Dry::Data container
Dry::Data.register(:user, User.method(:new), coercible_from: Hash)

user = Dry::Data[:user][name: :Jane, age: '21']

user.name # => "Jane"
user.age # => 21
```

## WIP

This is early alpha with a rough plan to:

* Add constrained types (ie a string with a strict length, a number with a strict range etc.)
* Add support for `Optional`/`Maybe` type to be able to explicitly specify that a given value could be nil (aka ActiveSupport `try` done right)
* Benchmark against other libs and make sure it's fast enough

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Benchmarks

You can run the benchmarks by running `bin/benchmark` from the console, you will note that we are slower than `fast_attributes`, and we probably always will be, however, we are not willing to stoop to the levels[<sup><a href="#fast_attributes">1</a></sup>] that they have in order for a slight performance gain, and feel that `dry-data` offers much more flexibility.

<sup><a name="fast_attributes">1</a></sup> fast_attributes generates code that gets `eval`'d to generate a class with setter methods containing a `case` statement to check each type and handle coercion individually. Further reading:

1. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes.rb#L53-L57" target="_blank">FastAttributes.attribute</a>
2. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes/builder.rb#L48-L59" target="_blank">FastAttributes::Builder#compile_setter</a>
3. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes/type_cast.rb#L72-L78" target="_blank">FastAttributes::TypeCast.compile_method_body</a>
4. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes/type_cast.rb#L45-L62" target="_blank">FastAttributes::TypeCast.type_casting_template</a>
5. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes/builder.rb#L21-L34" target="_blank">FastAttributes::Builder#compile!</a>
6. <a href="https://github.com/applift/fast_attributes/blob/master/lib/fast_attributes/builder.rb#L84-L91" target="_blank">FastAttributes::Builder#include_methods</a>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dryrb/dry-data.
