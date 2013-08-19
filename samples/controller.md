    ```Ruby
    class UsersController < ActionController::Base
      extend Auditable
      include Emailable

      login_user

      before_action :user_params
      after_action :refresh_password

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

      private

        def user_params
          # ...
        end

        def refresh_password
          # ...
        end
    end
    ```
