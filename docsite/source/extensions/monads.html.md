---
title: Monads
layout: gem-single
name: dry-types
---

The `:monads` extension provides a `#to_monad` method that returns a `Result` compatible with [`dry-monads`](/gems/dry-monads/).

The `.try` method returns a simple `Result` that's defined within `dry-types` (i.e. `Dry::Types::Result`).
If you want to use the result with `dry-monads`, you can load this extension and call `#to_monad` on the `Dry::Types::Result` to get a `Result` that's defined in `dry-monads` (i.e. `Dry::Monads::Result`). This will let you use the `dry-monads` methods on the result.

To enable the `:monads` extension:

```ruby
require 'dry/types'
Dry::Types.load_extensions(:monads)
Types = Dry.Types()
```

After loading the extension, you can leverage the `.to_monad` method:

```ruby
result = Types::String.try('Jane')
result.class            # => Dry::Types::Result::Success
monad = result.to_monad # => Success("Jane")
monad.class             # => Dry::Monads::Result::Success
monad.value!            # => 'Jane'

result = Types::String.try(nil)
result.class            # => Dry::Types::Result::Failure
monad = result.to_monad # => Failure([...])
monad.class             # => Dry::Monads::Result::Failure
monad.failure           # => [#<Dry::Types::ConstraintError: ...>, nil]
monad
  .fmap { |result| puts "passed: #{result.inspect}" }
  .or   { |error, input| puts "input '#{input.inspect}' failed with error: #{error.to_s}" }
```

Note that you must use the `.try` method and not the `.[]` method, since that skips the intermediate `Result` object and just returns the value. If you want to use the `.[]` method and also have errors be raised rather than captured in `Failure`, then you can consider using the [`:maybe` extension](docs::extensions/maybe) instead.

## `dry-monads` Do notation
This can be useful with [`do` notation](/gems/dry-monads/1.3/do-notation/) in `dry-monads`.

```ruby
require 'dry/types'
require 'dry/monads'
Types = Dry.Types()
Dry::Types.load_extensions(:monads)

class AddTen
  include Dry::Monads[:result, :do]

  def call(input)
    integer = yield Types::Coercible::Integer.try(input)

    Success(integer + 10)
  end
end

add_ten = AddTen.new

add_ten.call(10)
# => Success(20)

add_ten.call('integer')
# => Failure([#<Dry::Types::CoercionError: invalid value for Integer(): "integer">, "integer"])
```
