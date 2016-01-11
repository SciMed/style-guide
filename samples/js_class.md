```coffee
class window.SomeClass
  defaults: 
    foo: 'bar'
    url: 'www.google.com'
    
  constructor: ($someElement, otherVariable) ->
    @$someElement = $someVariable 
    @otherVariable = otherVariable
    @doSomeStuff()
    
  doSomeStuff: ->
    @$someElement.on 'click' =>
      console.log @otherVariable
    
    
$ ->
  $fooBar = $('#fooBar')
  mew window.SomeClass($fooBar, 'Hello') if $fooBar.length 
  
```
