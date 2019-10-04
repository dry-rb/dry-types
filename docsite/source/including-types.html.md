---
title: Including Types
layout: gem-single
name: dry-types
---

To include all built-in types in your own namespace simply do:

``` ruby
module Types
  include Dry::Types.module
end
```

Now you can access all built-in types inside your namespace:

``` ruby
Types::Coercible::String
# => #<Dry::Types::Constructor type=#<Dry::Types::Definition primitive=String options={}>>
```

With types accessible as constants you can easily compose more complex types:

``` ruby
module Types
  include Dry::Types.module

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  Age = Integer.constrained(gt: 18)
end

class User < Dry::Struct
  attribute :name, Types::String
  attribute :email, Types::Email
  attribute :age, Types::Age
end
```

You can also use dry-structs themselves as types:

```ruby
class Message < Dry::Struct
  attribute :body, Types::String
  attribute :to, User
end
```
