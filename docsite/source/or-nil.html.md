---
title: Or Nil
layout: gem-single
name: dry-types
---

Sometimes, it is useful to simply "nilify" invalid values instead failing. For example, imagine you want to accept `secondary_email` address, but it's OK to leave it nil if it is not valid. To accomplish this, you can:

``` ruby
secondary_email = Types::String.constrained(format: URI::MailTo::EMAIL_REGEXP).or_nil

secondary_email["jane@doe.org"]
# => "jane@doe.org"

secondary_email["jane"]
# => nil
```
