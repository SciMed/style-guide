Bad:
```html
<link href="https://fonts.googleapis.com/css?family=Rammetto+One" rel="stylesheet">
<link href="https://fonts.googleapis.com/css?family=Supermercado+One" rel="stylesheet">
```

```scss
@import url('https://fonts.googleapis.com/css?family=Rammetto+One');
@import url('https://fonts.googleapis.com/css?family=Supermercado+One');
```

Good:
```html
<link href="https://fonts.googleapis.com/css?family=Rammetto+One|Supermercado+One" rel="stylesheet">
```

```scss
@import url('https://fonts.googleapis.com/css?family=Rammetto+One|Supermercado+One');
```
