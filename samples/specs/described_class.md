```Ruby
# BAD
describe Foo do
  subject { Foo.new }
end

# GOOD
describe Foo do
  subject { described_class.new }
end
```
