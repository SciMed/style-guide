Suppose we have a state which looks like this:

```js
// The state object itself has to be a POJSO, but the state object should
// contain only ImmutableJS objects
state = {
  $$animalWhispererState: Immutable.fromJS({
    whispering: false,
    currentAnimal: 1,
    entities: {
      animals: {
        1: {
          id: 1,
          animalTypeId: 1
        },
        2: {
          id: 2,
          animalTypeId: 2
      },
      animalTypes: {
        1: {
          id: 1,
          name: 'dog',
          lnguageId: 1
        },
        2: {
          id: 2,
          name: 'cat',
          languageId: 2
        }
      },
      languages: {
        1: {
          id: 1,
          words: ['woof', 'bark', 'grr']
        },
        2: {
          id: 2,
          words: ['meow', 'purr']
        }
      }
    }
  })
}
```

All Redux containers get access to the full state tree, and they must figure out
what they need to know by reading the tree. Use selector functions to hide the
state shape from the containers.
```js
export const getAnimalWhispererState = (state) => {
  return state.$$animalWhispererState;
};

export const getEntities = (state) => {
  return getAnimalWhispererState(state).get('entities');
};

export const getAnimalTypes = (state) => {
  return getEntities(state).get('animalTypes');
};

export const getLanguages = (state) => {
  return getEntities(state).get('languages');
};

export const getAnimalTypeByName = (state, typeName) => {
  // use reselect's createSelector function to compose and transform selectors
  return createSelector([getAnimalTypes], ($$animalTypes) => {
    let animalType;
    $$animalTypes.forEach(($$animalType) => {
      if ($$animalType.get('name') === typeName) {
        animalType = $$animalType;
        return false; // breaks out of Immutable.Iterable forEach
      }
    });
    return animalType;
  })(state);
};

export const getLanguage = (state, id) => {
  // use createSelector even in this simple case because this will be memoized
  // by reselect - if getLanguages returns same thing, result is cached
  return createSelector([getLanguages], ($$languages) => {
    return $$languages.get(id.toString());
  })(state);
};

export const getLanguageWords = (state, id) => {
  return createSelector([getLanguage], ($$language) => {
    return $$language.get('words');
  })(state, id);
};

// Suppose we want to get the words an animal can speak using the name of the
// animal, e.g. 'dog'
export const getWordsForAnimal = (state, animalTypeName) => {
  return createSelector([getAnimalTypeByName], ($$animalType) => {
    // could refactor this $$animalType.get('languageId') into separate selector
    return getLanguageWords(state, $$animalType.get('languageId'));
  })(state, animalTypeName);
};
```
