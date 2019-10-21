---
title: Getting Started
layout: gem-single
name: dry-types
---

### Using `Dry::Types` in Your Application

1. Make `Dry::Types` available to the application by creating a namespace that includes `Dry::Types`:

    ```ruby
    require 'dry-types'
    module Types
      include Dry.Types()
   
      class << self
        # @param String The key of the Dry::Type -- see Dry::Types.type_keys
        def [] (type_key)
          Dry::Types[type_key]
        end
        Dry::Types.type_keys.each do |method_name|
          define_method method_name do
            Dry::Types[method_name]
          end
        end
      end
    end
    ```
   
2. Reload the environment, & type `Types.string` in the ruby console to confirm it worked:

    ``` ruby
    Types.string
    # => #<Dry::Types[Constrained<Nominal<String> rule=[type?(String)]>]>
    ```

### Creating Your First Type

1. Define a struct's types by passing the name & type to the `attribute` method:

    ```ruby
    class User < Dry::Struct
      attribute :name, Types.string
    end
    ```

2. Define [Custom Types](/gems/dry-types/1.0/custom-types) in the `Types` module, then pass the name & type to `attribute`:

    ```ruby
    module Types
      include Dry.Types()
    
      Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
      Age = Integer.constrained(gt: 18)
    end
    class User < Dry::Struct
      attribute :name, Types.string
      attribute :email, Types::Email
      attribute :age, Types::Age
    end
    ```

3. Use a `Dry::Struct` as a type:

    ```ruby
    class Message < Dry::Struct
      attribute :body, Types.string
      attribute :to, User
    end
    ```
