```Ruby
# Bad
it 'should return "hello_world"' do
  expect(subject.hello_world).to eql 'hello_world'
end

# Good
it 'returns "hello_world"' do
  expect(subject.hello_world).to eql 'hello_world'
end
```
