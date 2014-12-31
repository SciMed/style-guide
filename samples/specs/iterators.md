```Ruby
# BAD
describe 'IntegerProperties' do
  describe '#even?' do
    [2,4,6,8].each do |x|
      it 'returns true' do
        expect(subject.even?(x)).to eql true
      end
    end
  end
end

# GOOD
describe 'IntegerProperties' do
  describe '#even?' do
    it 'returns true' do
      expect(subject.even?(2)).to eql true
    end
    it 'returns true' do
      expect(subject.even?(4)).to eql true
    end
    it 'returns true' do
      expect(subject.even?(6)).to eql true
    end
    it 'returns true' do
      expect(subject.even?(8)).to eql true
    end
  end
end
```
