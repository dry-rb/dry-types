---
title: Monads
layout: gem-single
name: dry-types
---

The monads extension makes `Dry::Types::Result` objects compatible with `dry-monads`.

To enable the extension:

```ruby
require 'dry/types'
Dry::Types.load_extensions(:monads)
```

After loading the extension, you can leverage monad API:

```ruby
Types = Dry.Types()

result = Types::String.try('Jane')
result.class #=> Dry::Types::Result::Success
monad = result.to_monad
monad.class #=> Dry::Monads::Result::Success
monad.value!  # => 'Jane'
result = Types::String.try(nil)
result.class #=> Dry::Types::Result::Failure
monad = result.to_monad
monad.class #=> Dry::Monads::Result::Failure
monad.failure  # => [#<Dry::Types::ConstraintError>, nil]
Types::String.try(nil)
  .to_monad
  .fmap { |result| puts "passed: #{result.inspect}" }
  .or   { |error, input| puts "input '#{input.inspect}' failed with error: #{error.to_s}" }
```

This can be useful when used with `dry-monads` and the [`do` notation](/gems/dry-monads/1.0/do-notation/):

```ruby
require 'dry/types'
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
