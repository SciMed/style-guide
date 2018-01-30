```Ruby
# BAD
### Expects exactly one book to exist before running the test, and exactly 2 after.
describe Bookbag do
  subject do
    book1 = Book.new
    subject = described_class.new(books: [book1])
    subject.save
    subject
  end

  describe '#add_book' do
    it 'changes the book count to 2' do
      book2 = Book.create!
      subject.add_book(book2)
      expect(subject.books.count).to eql 2
    end
  end
end

# GOOD
### Just checks to make sure there is one more book than before, which is less brittle.
describe Bookbag do
  subject do
    book1 = Book.new
    subject = described_class.new(books: [book1])
    subject.save
    subject
  end

  describe '#add_book' do
    it 'increases the book count by 1' do
      book2 = Book.create!
      expect { subject.add_book(book2) }.to change { subject.books.count }.by(1)
    end
  end
end
```
