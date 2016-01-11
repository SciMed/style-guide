application.coffee:

```coffee
...
$ ->
  $body = $('body')
  window.Initializers.init($body)
  
  $body.on 'cocoon:after-insert' ($newField) ->
    window.Initializers.init($newField)
```

initializers.coffee:

```coffee
window.Initializers = do ->

  init = ($scope) ->
    select2($scope)
    bestInPlace($scope)
    datePicker($scope)
    tooltip($scope)

  select2 = ($scope) ->
    $scope.find('.select2').select2
      allowClear: true
      placeholder: 'Select Option'

  bestInPlace = ($scope) ->
    $scope.find(".best_in_place").best_in_place()

  datePicker = ($scope) ->
    $scope.find('.bootstrap-date-field').datepicker()

  tooltip = ($scope) ->
    $scope.find("[data-toggle='tooltip']").tooltip()


  # public functions:
  init: ($scope) -> init($scope)
```


