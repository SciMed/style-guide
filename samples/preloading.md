```ruby
# bad
class Foo < ApplicationRecord
  has_many :bars
end

Foo.includes(:bars).map { |foo| foo.bars.where(baz: true) }

# Why is this bad? It fires off the following queries:
#
# One to load the foos
# One to run the `include`
# `n` for `bars.where(baz: true)`
#
# In addition, the `bars` from the `includes` get loaded into memory. This
# will lead to more garbage collection.

# good
class Foo < ApplicationRecord
  has_many :bars
  has_many :bazzy_bars, -> { where(baz: true) }, class_name: 'Bar'
end

Foo.includes(:bars).map { |foo| foo.bars.select(&:baz?) }
Foo.includes(:bazzy_bars).map { |foo| foo.bazzy_bars } # Most performant
```
