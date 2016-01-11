```coffee
window.SomeClass = do ->
  self = {}
  initialized = false
  
  init = ->
    unless initialized
      initialized = true
      self.$foo = $('#foo')
      setInitialState()
      bindEvents()
      
  setInitialState = ->
    calculateSum()
    
  bindEvents = ->
    bindAddSum()
    
  calculateSum = ->
    self.sum ||= 0
    $('.sum').each ->
      sum = $(@).attr('data-sum')
      self.sum = self.sum + sum
      
  bindAddSum = ->
    self.$foo.on 'click' ->
      $(@).append($('<div class="sum" data-sum="10"></div>'))
      calculateSum()
      
  # public functions
  init: init
  
$ ->
  window.SomeClass.init() if $('#foo').length

```
