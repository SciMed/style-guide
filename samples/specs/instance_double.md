```Ruby
# BAD
let(:foo) do
  double 'Foo'
end

# GOOD
let(:foo) do
  instance_double 'Foo'
end

# For ActiveRecord objects, use object_double, as attribute
# methods on ActiveRecord objects are defined using method_missing
# and therefore won't be recognized by instance_double.
let(:foo) do
  object_double Foo.new
end
```
