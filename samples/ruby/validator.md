```Ruby
# Bad
class Racecar < Car
  validates :must_have_a_drink_sponsor

  def must_have_a_drink_sponsor
    # ...
  end
end

# Good
class Validators::RacecarValidator < ActiveModel::EachValidator
  def validate(record)
    must_have_a_drink_sponsor(record)
  end

  def must_have_a_drink_sponsor
    unless record.sponsor_names.include?('Powerthirst')
      record.errors[:base] << 'Your racecar must have a drink sponsor.'
    end
  end
end

class Racecar
  validates_with Validators::RacecarValidator
end
```
