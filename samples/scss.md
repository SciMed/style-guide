#SCSS Whitespace Guidelines

* One line after section comment
* One line before section comment
* One line before each selector's css declaration

```scss
/* BASE */

body {
  box-sizing: border-box;
}

/* MODULES */

.page-title {
  margin: 10px;

  h1 {
    display: inline;
  }

  > div {
    margin: 10px;
  }
}

#results {
  .sort_link {
    background:none !important;
  }

  form.button_to {
    margin: 0;
  }
}
```
