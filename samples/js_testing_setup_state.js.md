Example setup functions for Redux state. Using these functions across all tests
which rely on the state ensures that the shape of the state used in your tests
remains the same across all tests. Using setup functions also makes it easier to
change parts of the state for different test contexts.

```
export const setupEntites({
  $$animals = Immutable.fromJS({}),
  $$animalTypes = Immutable.fromJS({}),
  $$languages = Immutable.fromJS({})
  }) => {
  return Immutable.fromJS({
    animals: $$animals,
    animalTypes: $$animalTypes,
    languages: $$languages
  });
};

export const setupAnimalWhispererState({
  $$entities = setupEntities({}),
  currentAnimal = null,
  whispering = false
  }) => {
  return Immutable.fromJS({
    entities: $$entities,
    currentAnimal,
    whispering
  });
};

export const setupState = ({
  $$animalWhispererState = setupAnimalWhispererState({})
  }) => {

  const state = {
    $$animalWhispererState
  };

  return { state };
};

// Example container setup function. This function will probably be needed for
every container test.
export const setupContainer = ({state = setupState({}).state, containerClass,
containerProps}) => {
  const store = {
    getState: () => {
      return state;
    },
    subscribe: () => {},
    dispatch: () => {}
  };

  const container = React.createElement(containerClass, containerProps);
  const component = mount(
    <Provider store={store}>
      {container}
    </Provider>
  );
  return { component }
};
```
