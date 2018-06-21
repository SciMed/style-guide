```Ruby
# Bad
let(:foo) do
  double 'Foo' # Does not do verification
end

# Good
let(:foo) do
  instance_double 'Foo' # Does verification that methods exist on Foo and accept the given parameters.
end

# For ActiveRecord objects, use object_double, as attribute
# methods on ActiveRecord objects are defined using method_missing
# and therefore won't be recognized by instance_double.
let(:foo) do
  object_double Foo.new
end
```
