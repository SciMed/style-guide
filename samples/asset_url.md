```scss
/* Good */
// my-styles.css.scss.erb
.aside {
  background-image: asset-url('bg_image.png', image);
}

// my-styles.css.scss
/* Bad */
.aside {
  background-image: url('/assets/bg_image.png');
}
```
