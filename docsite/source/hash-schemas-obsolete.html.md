---
title: Hash Schemas (deprecated API)
layout: gem-single
name: dry-types
---

### [DEPRECATED] The following API is already removed in 0.15, use new configurable hash schemas as a replacement.

The built-in `Hash` type has constructors that you can use to define hashes with explicit schemas and coercible values using the built-in types. The different constructor types support different use cases that involve unexpected keys, missing keys, default values, and key coercion.

Hash schemas are typically used under the hood of other libraries. In example dry-validation uses `:symbolized` schema in `Form` validations, which safely processes values in a hash and returns output with symbolized keys or dry-struct uses hash schemas to process struct attributes. If you want to use hash schemas standalone, or configure them for your dry structs, it's important to understand differences in behavior:

### Input contains a value with an invalid type

| constructor type      | Behavior                         |
| :----                 | :---                             |
| `:schema`               | Raises an error                  |
| `:weak`                 | Includes invalid value in output |
| `:permissive`           | Raises an error                  |
| `:strict`               | Raises an error                  |
| `:strict_with_defaults` | Raises an error                  |
| `:symbolized`           | Includes invalid value in output |

### Input omits a key for a value that does not have a default

| constructor type      | Behavior                         |
| :----                 | :---                             |
| `:schema`               | Produces output without that key |
| `:weak`                 | Produces output without that key |
| `:permissive`           | Raises an error                  |
| `:strict`               | Raises an error                  |
| `:strict_with_defaults` | Raises an error                  |
| `:symbolized`           | Produces output without that key |

### Input omits a key for a value that has a default

| constructor type      | Behavior               |
| :----                 | :---                   |
| `:schema`               | Fills in default value |
| `:weak`                 | Fills in default value |
| `:permissive`           | Raises an error        |
| `:strict`               | Raises an error        |
| `:strict_with_defaults` | Fills in default value |
| `:symbolized`           | Fills in default value |

### Input includes a key that was not specified in the schema

| constructor type      | Behavior                    |
| :----                 | :---                        |
| `:schema`               | Omits the unspecified value |
| `:weak`                 | Omits the unspecified value |
| `:permissive`           | Omits the unspecified value |
| `:strict`               | Raises an error             |
| `:strict_with_defaults` | Raises an error             |
| `:symbolized`           | Omits the unspecified value |

### Input contains `nil` for a value that specifies a default

| constructor type      | Behavior               |
| :----                 | :---                   |
| `:schema`               | Fills in default value |
| `:weak`                 | Fills in default value |
| `:permissive`           | Fills in default value |
| `:strict`               | Raises an error        |
| `:strict_with_defaults` | Raises an error        |
| `:symbolized`           | Fills in default value |

### Input contains string keys instead of symbol keys

| constructor type      | Behavior                       |
| :----                 | :---                           |
| `:schema`               | Raises an error                |
| `:weak`                 | Raises an error                |
| `:permissive`           | Raises an error                |
| `:strict`               | Raises an error                |
| `:strict_with_defaults` | Raises an error                |
| `:symbolized`           | Coerces string keys to symbols |

## Example Usage

### Hash Schema

``` ruby
# using simple kernel coercions
hash = Types::Hash.schema(name: Types::String, age: Types::Coercible::Integer)

hash[name: 'Jane', age: '21']
# => { :name => "Jane", :age => 21 }

# using form param coercions
hash = Types::Hash.schema(name: Types::String, birthdate: Form::Date)

hash[name: 'Jane', birthdate: '1994-11-11']
# => { :name => "Jane", :birthdate => #<Date: 1994-11-11 ((2449668j,0s,0n),+0s,2299161j)> }
```

### Permissive Schema

Permissive hash will raise errors when keys are missing or value types are incorrect.

``` ruby
hash = Types::Hash.permissive(name: Types::String, age: Types::Coercible::Integer)

hash[email: 'jane@doe.org', name: 'Jane', age: 21]
# => Dry::Types::SchemaKeyError: :email is missing in Hash input
```

### Symbolized Schema

Symbolized hash will turn string key names into symbols

``` ruby
hash = Types::Hash.symbolized(name: Types::String, age: Types::Coercible::Integer)

hash['name' => 'Jane', 'age' => '21']
# => { :name => "Jane", :age => 21 }
```
