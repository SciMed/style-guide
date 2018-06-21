All JavaScript objects should be namespaced under `window`

```coffee
class window.Foo
  constructor: ->
    console.log 'foo'

$ ->
  new window.Foo
```

Related JavaScript should be further namespaced:

```coffee
window.SomeComponent ||= {} # this is required to ensure that SomeComponent exists before adding an object on it

class window.SomeComponent.Things
  constructor: ->
    console.log 'some component-namespaced things'

class window.SomeComponent.OtherThings
  constructor: ->
    console.log 'some component-namespaced other things'
```
