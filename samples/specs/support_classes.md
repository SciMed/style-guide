Use anonymous classes to prevent the possibility of a constant collision:

```rb
# Bad
class SomeThingForTests
  def initialize(foo)
    @foo = foo
  end
  
  def bar
    @foo * 2
  end
end

# Good
let(:some_thing_for_tests) do
  Class.new do
    def initialize(foo)
      @foo = foo
    end
  
    def bar
      @foo * 2
    end
  end
end
```
