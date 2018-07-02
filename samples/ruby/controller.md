```Ruby
class UsersController < ActionController::Base
  extend Auditable
  include Emailable

  # Permissions statements, e.g.
  power :clients

  login_user

  before_action :user_params
  after_action :refresh_password

  layout 'main_layout'

  # Place all non-standard actions before standard RESTful actions
  def search
    # ...
  end

  def index
   # ...
  end

  # def show...
  # def new...
  # def create...
  # def edit...
  # def update...
  # def destroy...

  private def user_params
    # ...
  end

  private def refresh_password
    # ...
  end
end
```
