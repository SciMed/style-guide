```Ruby

# BAD
subject.foo.should eql 'foo'

# GOOD
expect(subject.foo).to eql 'foo'

```
