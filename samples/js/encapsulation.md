```coffee
window.SomeClass = do ->
  self = {}
  initialized = false

  init = ->
    unless initialized
      initialized = true
      self.$foo = $('#foo')
      # utilize these functions for state and behavior:
      setInitialState()
      bindEvents()

  setInitialState = ->
    calculateSum()

  bindEvents = ->
    # all methods binding events should begin with 'bind'
    bindAddSum()

  calculateSum = ->
    self.sum ||= 0
    $('.sum').each ->
      sum = $(@).attr('data-sum')
      self.sum = self.sum + sum

  bindAddSum = ->
    self.$foo.on 'click' ->
      $(@).append($('<div class="sum" data-sum="10"></div>'))
      # because calculateSum is just a variable on the object, you do not need to use the fat arrow to access it
      calculateSum()

  # public functions
  init: init


$ ->
  window.SomeClass.init() if $('#foo').length

```
