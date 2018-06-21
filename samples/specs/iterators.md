```Ruby
# Bad
describe 'IntegerProperties' do
  describe '#even?' do
    [2, 4, 6, 8].each do |x|
      it 'returns true' do
        expect(subject.even?(x)).to eql true
      end
    end
  end
end

# Good
describe 'IntegerProperties' do
  describe '#even?' do
    it 'returns true for 2' do
      expect(subject.even?(2)).to eql true
    end
    it 'returns true for 4' do
      expect(subject.even?(4)).to eql true
    end
    it 'returns true for 6' do
      expect(subject.even?(6)).to eql true
    end
    it 'returns true for 8' do
      expect(subject.even?(8)).to eql true
    end
  end
end
```
