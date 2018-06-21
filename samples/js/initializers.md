application.coffee:

```coffee
...
$ ->
  $body = $('body')
  new window.Initializers($body)

  $body.on 'cocoon:after-insert' ($newField) ->
    new window.Initializers($newField)
```

initializers.coffee:

```coffee
class window.Initializers
  constructor: ($scope) ->
    @$scope = $scope
    @select2
    @bestInPlace
    @datePicker
    @tooltip

  select2: ->
    @$scope.find('.select2').select2
      allowClear: true
      placeholder: 'Select Option'

  tooltip: ->
    @$scope.find("[data-toggle='tooltip']").tooltip()
```
