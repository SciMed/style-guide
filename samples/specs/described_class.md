```Ruby
# Bad
describe Foo do
  subject { Foo.new }
end

# Good
describe Foo do
  subject { described_class.new }
end
```
