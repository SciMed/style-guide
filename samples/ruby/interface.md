When creating an interface-like module, do not define a dummy implementation of
the methods that are expected to be defined by implementers of the interface.
Instead, use comments to list the expected methods and their method signatures.
In particular, [do not define methods that raise
`NotImplementedError`](https://oleg0potapov.medium.com/ruby-notimplementederror-dont-use-it-dff1fd7228e5).

In addition, create a shared example that can be used by all classes that
include the module so that the tests will catch any objects that do not conform
to the interface.

```rb
# Bad

# app/services/animal.rb

module Animal
  # @param food [Food]
  # @return [void]
  def eat(food)
    raise NotImplementedError
  end
end

# Good

# app/services/animal.rb

# All classes implementing this interface should define the following methods.
module Animal
  # @param food [Food]
  # @return [void]
  # def eat(food)
  # end
end

# spec/support/shared_examples/animals.rb

RSpec.shared_examples 'an animal' do
  describe 'interface' do
    it { is_expected.to respond_to(:eat) }
  end
end
```
