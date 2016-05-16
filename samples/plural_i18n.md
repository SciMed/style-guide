### I18n Pluralization example

Source: http://guides.rubyonrails.org/i18n.html#pluralization

```
I18n.backend.store_translations :en, inbox: {
  one: 'one message',
  other: '%{count} messages'
}
```

