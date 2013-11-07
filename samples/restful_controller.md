```Ruby
class UsersController < ActionController::Base
  # good
  def search
    # ...
  end

  # bad
  def create_comment
    # ...
  end
end
```
