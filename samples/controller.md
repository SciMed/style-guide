```Ruby
class UsersController < ActionController::Base
  extend Auditable
  include Emailable

  login_user

  before_action :user_params
  after_action :refresh_password
  
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

  def user_params
    # ...
  end
  private :user_params

  def refresh_password
    # ...
  end
  private :refresh_password
end
```
