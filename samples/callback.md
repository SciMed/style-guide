    ```Ruby
    # Bad
    class User < ActiveRecord
      belongs_to :api_key

      before_save :geolocate_address
      after_save :refresh_api_key

      private

        # def geolocate_address...
        # def refresh_api_key...
    end

    # Good
    class User < ActiveRecord
      belongs_to :api_key
    end

    class UserPersistor
      attr_accessor :user

      def initialize(user)
        self.user = user
      end

      def create
        user.transaction { geolocate_address && user.save && refresh_api_key }
      end

      def geolocate_address
        user.coordinates = GeoAPI.get_coordinates(user.address)
      end

      def refresh_api_key
        user.api_key.destroy
        user.api_key.create(key: rand(10))
      end
    end

    class UsersController
      def create
        @user = User.new(user_params)
        if UserPersistor.new(@user).create
          # ...
        end
      end
    end
    ```
