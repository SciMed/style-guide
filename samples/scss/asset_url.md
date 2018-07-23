```scss
/* Bad */
// my_styles.scss
.aside {
  background-image: url('/assets/bg_image.png');
}

/* Good */
// my_styles.scss.erb
.aside {
  background-image: asset-url('bg_image.png', image);
}
```
