### Example of a custom inflector

Source: http://api.rubyonrails.org/classes/ActiveSupport/Inflector/Inflections.html

```ruby
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural /^(ox)$/i, '\1\2en'
  inflect.singular /^(ox)en/i, '\1'

  inflect.irregular 'octopus', 'octopi'

  inflect.uncountable 'equipment'
end
```
