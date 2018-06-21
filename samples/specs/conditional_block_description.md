```Ruby
# Bad
describe IntegerProperties do
  describe '#even?' do
    it 'returns true if the argument is an even integer' do
      expect(subject.even?(2)).to eql true
    end
    it 'returns false if the argument is an odd integer' do
      expect(subject.even?(3)).to eql false
    end
  end
end

# Good
describe IntegerProperties do
  describe '#even?' do
    context 'when argument is an even integer' do
      it 'returns true' do
        expect(subject.even?(2)).to eql true
      end
    end

    context 'when argument is an odd integer' do
      it 'returns false' do
        expect(subject.even?(3)).to eql false
      end
    end
  end
end
```
