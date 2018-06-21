```Ruby
class UsersController < ActionController::Base
  # Bad
  def create_comment
    # ...
  end

  # Good
  def search
    # ...
  end
end
```
