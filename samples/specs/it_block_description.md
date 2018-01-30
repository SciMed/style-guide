```Ruby
# BAD
it 'returns "hello_world"' do
  expect(subject.hello_world).to eql 'hello_world'
end

# GOOD
it 'returns "hello_world"' do
  expect(subject.hello_world).to eql 'hello_world'
end
```
