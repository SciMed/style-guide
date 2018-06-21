# Bad

```HTML
<a class="button button-large"></a>
```

# Good

```HTML
<a class="save"></a>
```

```CSS
.save {
  @include button;
  @include button-large;
  color: #fff;
}
```
