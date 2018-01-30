### Bad

```HTML
<a href="/">
  <image src="logo.png">
</a>
```

### Good

```HTML
<a href="/" class="logo"></a>
```

```CSS
.logo {
  background-image: url('logo.png');
  background-repeat: no-repeat;
  display: inline-block;
  height: 200px;
  width: 500px;
}
```
