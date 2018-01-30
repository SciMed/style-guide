```scss
// my-styles.scss
/* Bad */
.aside {
  background-image: url('/assets/bg_image.png');
}

/* Good */
// my-styles.scss.erb
.aside {
  background-image: asset-url('bg_image.png', image);
}
```
