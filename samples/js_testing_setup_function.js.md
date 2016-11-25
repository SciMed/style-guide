```
describe('AnimalWhisperer', () => {
  const setup = ({ animal }) => {
    const whisperer = new AnimalWhisperer(animal);
    return { whisperer };
  };

  context('when the animal is a cat', () => {
    let animal = { type: 'cat', language: 'meow' };
    let { whisperer } = setup({animal});

    it('speaks the cat language', () => {
      expect(whisperer.talkToAnimal()).to.eql('meow meow cat');
    });
  });
  context('when the animal is a dog, () => {
    let animal = { type: 'dog', language: 'woof' };
    let { whisperer } = setup({animal});

    it('speaks the dog language', () => {
      expect(whisperer.talkToAnimal()).to.eql('woof woof dog');
    });
  });
});
```
