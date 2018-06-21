```Ruby
# Bad
subject.foo.should eql 'foo'

# Good
expect(subject.foo).to eql 'foo'
```
