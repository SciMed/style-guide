```Ruby
class UsersController < ActionController::Base
  # bad
  def create_comment
    # ...
  end

  # good
  def search
    # ...
  end
end
```
