```
require 'rails_helper'

RSpec.describe Foo do
  let(:bar) { 'bar' }

  subject { described_class.new }

  describe '.some_class_method' do
    let(:bar2) { 'bar2' }
    let(:bar3) { 'bar3' }

    subject { described_class }

    before do
      visit foos_path
    end

    context 'when buzz' do
      it 'does something' do
        ...
      end
      it 'does something else' do
        ...
      end
    end

    context 'when fizz' do
      ...
    end
  end

  describe '#some_instance_method' do
    ...
  end
end
```
