```Ruby
# BAD
let(:foo) do
  double 'Foo'
end

# GOOD
let(:foo) do
  instance_double 'Foo'
end
```
