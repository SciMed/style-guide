in `app/client/packs/application.js` (or another file that is always loaded)

```js
$(document).ready(() => new Initializer($('body')).initialize());

```


in `initializer.js`:

```js
export default class Initializer {
  constructor($scope) {
    this.$scope = $scope;
  }

  initialize() {
    this.initializeTooltips();
    this.initializeDatePickers();
  }

  initializeTooltips() {
    const $tooltips = this.$scope.find('[data-content]');
    $tooltips.each((index, element) => {
      const $element = $(element);
      const useInlinePopup = $element.data('inline');
      $element.popup({ inline: useInlinePopup, lastResort: 'bottom center' });
    });
  }

  initializeDatePickers() {
    const $datePickers = this.$scope.find('[data-date-picker]');
    $datePickers.each((index, element) => new DatePicker($(element)).init());
  }
}
```
