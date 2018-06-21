```coffee
class window.SomeClass
  defaults:
    foo: 'bar'
    url: 'www.google.com'

  @someClassVariable: 'foo'

  constructor: ($someElement, otherVariable) ->
    @$someElement = $someVariable
    @otherVariable = otherVariable
    @doSomeStuff()

  doSomeStuff: ->
    # in order to access class variables (like @otherVariable), use the fat arrow
    @$someElement.on 'click' =>
      console.log @otherVariable

  @someClassMethod: ->
    console.log 'A class method'


$ ->
  $fooBar = $('#fooBar')

  # instantiates a new object:
  new window.SomeClass($fooBar, 'Hello') if $fooBar.length

  # calls a class method:
  window.SomeClass.someClassMethod()

  # calls a class variable (use very sparingly)
  window.SomeClass.someClassVariable
```
