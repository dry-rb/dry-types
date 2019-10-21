---
title: Getting Started
layout: gem-single
name: dry-types
---

### Using `Dry::Types` in Your Application

1. Make `Dry::Types` available to the application by creating a namespace that includes `Dry::Types`:

    ```ruby
    module Types
     include Dry.Types()
    end
    ```
   
2. Reload the environment, & type `Types::Coercible::String` in the ruby console to confirm it worked:

    ``` ruby
    Types::Coercible::String
    # => #<Dry::Types::Constructor type=#<Dry::Types::Definition primitive=String options={}>>
    ```

### Creating Your First Type

1. Define a struct's types by passing the name & type to the `attribute` method:

    ```ruby
    class User < Dry::Struct
      attribute :name, Types::String
    end
    ```

2. Define [Custom Types](docs::custom-types) in the `Types` module, then pass the name & type to `attribute`:

    ```ruby
    module Types
      include Dry.Types()
    
      Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
      Age = Integer.constrained(gt: 18)
    end
    class User < Dry::Struct
      attribute :name, Types::String
      attribute :email, Types::Email
      attribute :age, Types::Age
    end
    ```

3. Use a `Dry::Struct` as a type:

    ```ruby
    class Message < Dry::Struct
      attribute :body, Types::String
      attribute :to, User
    end
    ```
