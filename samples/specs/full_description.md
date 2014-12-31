```Ruby
# BAD

# GOOD
describe Foo do
  describe "#hello" do
    context "when an argument is passed in" do
      it "returns a string with the argument interpolated" do
        expect(subject.hello('SciMed')).to eql 'Hello, SciMed.'
      end
    end
    context "when no arguments are passed in" do
      it "returns 'hello'" do
        expect(subject.hello).to eql 'Hello.'
      end
    end
  end
end

## The full spec descriptions for these two specs are
"Foo#hello when an argument is passed in returns a string with the argument interpolated" and
"Foo#hello when no arguments are passed in returns 'hello'"
```
