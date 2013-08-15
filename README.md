# Prelude

> Role models are important. <br/>
> -- Officer Alex J. Murphy / RoboCop

The goal of this guide is to present a set of best practices and style
prescriptions for Ruby on Rails based on SciMed Solutions' years
of development experience.

You can generate a PDF or an HTML copy of this guide using
[Transmuter](https://github.com/TechnoGate/transmuter).

# Table of Contents

* [Developing Rails applications](#developing-rails-applications)
    * [Configuration](#configuration)
    * [Routing](#routing)
    * [Controllers](#controllers)
    * [Models](#models)
    * [Migrations](#migrations)
    * [Views](#views)
    * [Mailers](#mailers)
    * [Bundler](#bundler)

# Developing Rails applications

## Configuration

* Put custom initialization code in `config/initializers`. The code in
  initializers executes on application startup.
* Keep initialization code for each gem in a separate file
  with the same name as the gem, for example `carrierwave.rb`,
  `active_admin.rb`, etc.

## Routing

* Try to avoid adding non RESTful routes to a resource.
* Favor `resources`, `member`, and `collection` routes over `get`, `post`, `patch` matchers.
* If you need to define multiple `member/collection` routes use the
  alternative block syntax.

    ```Ruby
    resources :subscriptions do
      member do
        get 'unsubscribe'
        # more routes
      end

      collection do
        get 'search'
        # more routes
      end
    end
    ```

* Use nested routes to express better the relationship between
  ActiveRecord models.
* Avoid more than 1 level of resource nesting.

    ```Ruby
    # bad
    resources :users do
      resources :posts do
        resources :comments
      end
    end

    # good
    resources :users do
      resources :posts
    end

    resources :posts  do
      resources :comments
    end
    ```

* Use namespaced routes to group related actions.

    ```Ruby
    namespace :admin do
      # Directs /admin/products/* to Admin::ProductsController
      # (app/controllers/admin/products_controller.rb)
      resources :products
    end
    ```

* In Rails 3 and below, never use the legacy wildcard controller routes. This
  route will make all actions in every controller accessible via GET requests.

    ```Ruby
    # very bad
    match ':controller(/:action(/:id(.:format)))'
    ```

## Controllers

* Try to avoid adding non RESTful actions to a resource.
* Storing anything in session is discouraged.
* Keep the controllers skeletal - they should only retrieve data for the
  view layer and shouldn't contain any business logic (all the
  business logic should naturally reside in the model).
* Place non RESTful actions above RESTful actions in the controller. If a
  controller has more than a few non default actions, there is a high
  probability that another resource (and controller) is required.

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
  ```

* Each controller action should (ideally) invoke only one method other
  than an initial find or new.
* Share no more than two instance variables between a controller and a view.
* Remove generated `respond_to` blocks from controller actions unless needed.
* Remove generated comments on Controller actions.
* Structure Controller content in the following order:
  * Module `extend`
  * Module `include`
  * External library macros (like devise or cancan)
  * `*_filter` or `*_action` macros in chronological order.
  * Nondefault controller actions
  * Default controller actions
  * Private methods

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

## Models

* Using non-database-backed models is encouraged.
* Name the models with meaningful, succinct names without
  abbreviations.
* Do not camelcase acronyms in class names. Ruby has built-in support for
  upcased class names.

### ActiveRecord

* Avoid adding default_scope.
* Avoid adding callbacks in favor of an object decorator.

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

* Avoid adding callbacks if they are modifying other models.
* Group macro-style methods (`has_many`, `validates`, etc) in the
  beginning of the class definition.
* Structure class content in the following order:
  * Module `extend`
  * Module `include`
  * External library macros (like devise or paperclip)
  * `default_scope` (discouraged)
  * Constants (discouraged) [DISCUSS, CITE, MORE INFO]
  * `attr_accessible` (Rails 3 and below)
  * `accepts_nested_attributes_for`
  * Callbacks in chronological order.
  * `validate :custom_method` macros
  * `validates` macros in alphabetical order
  * `attr_accesor` attributes
  * `delegate` macros
  * `belongs_to` associations in alphabetical order
  * `has_many` associations in alphabetical order
  * `scope`
  * Public Class methods
  * Public Instance methods
  * Private Class methods
  * Private Instance methods

    ```Ruby
    class User < ActiveRecord::Base
      extend Auditable
      include Emailable

      default_scope { where(active: true) }

      has_attachment :document, resize_to_fit: true
      can_login, memorable: true

      GENDERS = %w(male female)

      attr_accessible :login, :first_name, :last_name, :email, :password

      accepts_nested_attributes_for :comments

      before_save :cook
      after_save :update_username_lower

      validate :within_time_period
      validate :currently_active_member

      validates :email, presence: true
      validates :password, format: { with: /\A\S{8,128}\z/, allow_nil: true}
      validates :username, presence: true
      validates :username, uniqueness: { case_sensitive: false }
      validates :username, format: { with: /\A[A-Za-z][A-Za-z0-9._-]{2,19}\z/ }

      attr_accessor :formatted_date_of_birth

      delegate :treats, to: :dog

      belongs_to :country
      belongs_to :city
      belongs_to :state
      has_many :authentications
      has_many :comments
      has_many :posts

      scope :administrators, -> { where(admin: true) }
      scope :active, -> { where(active: true) }

      def self.trim_inactive
        # ...
      end

      def calculate_age
        # ...
      end

      private

        def self.some
          # ...
        end

        def whatevs
          # ...
        end

    end
    ```
* Use of `class << self` is discouraged in ActiveRecord models.
* Use of `has_and_belongs_to_many` is strongly discouraged.  Use `has_many :through`
  instead. Using `has_many :through` allows additional attributes and validations
  on the join model.
* Order associations alphabetically by macro name, then model name.

* Always use the new
  ["sexy" validations](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/).

    ```Ruby
    # bad
    validates_presence_of :email

    # good
    validates :email, presence: true
    ```

* When a custom validation is used more than once or the validation is
some regular expression mapping, create a custom validator file.

    ```Ruby
    # bad
    class Person
      validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
    end

    # good
    class EmailValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors[attribute] << (options[:message] || 'is not a valid email') unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      end
    end

    class Person
      validates :email, email: true
    end
    ```

* Keep custom validators under `models/validators`.
* Consider extracting custom validators to a shared gem if you're
  maintaining several related apps or the validators are generic
  enough.
* Use named scopes freely.

    ```Ruby
    class User < ActiveRecord::Base
      scope :active, -> { where(active: true) }
      scope :inactive, -> { where(active: false) }

      scope :with_orders, -> { joins(:orders).select('distinct(users.id)') }
    end
    ```

* Wrap scopes in `lambdas` to initialize them lazily.

    ```Ruby
    # bad
    class User < ActiveRecord::Base
      scope :active, where(active: true)
      scope :inactive, where(active: false)

      scope :with_orders, joins(:orders).select('distinct(users.id)')
    end

    # good
    class User < ActiveRecord::Base
      scope :active, -> { where(active: true) }
      scope :inactive, -> { where(active: false) }

      scope :with_orders, -> { joins(:orders).select('distinct(users.id)') }
    end
    ```

* In Rails 3 and below, beware of the behavior of the `update_attribute` method. It doesn't
  run the model validations (unlike `update_attributes`) and could easily corrupt the model state.

## Migrations

* Keep the `schema.rb` (or `structure.sql`) under version control.
* Use `rake db:schema:load` instead of `rake db:migrate` to initialize
an empty database.
* Use `rake db:test:prepare` to update the schema of the test database.
* Enforce default values in the migrations themselves instead of in
  the application layer.

    ```Ruby
    # bad - application enforced default value
    def amount
      self[:amount] or 0
    end
    ```

    While enforcing table defaults only in Rails is suggested by many
    Rails developers it's an extremely brittle approach that
    leaves your data vulnerable to many application bugs.  And you'll
    have to consider the fact that most non-trivial apps share a
    database with other applications, so imposing data integrity from
    the Rails app is impossible.

* When writing constructive migrations (adding tables or columns), use
  the new Rails 3.1+ way of doing the migrations - use the `change`
  method instead of `up` and `down` methods.


* Don't use model classes in migrations. The model classes are
constantly evolving and at some point in the future migrations that
used to work might stop, because of changes in the models used.

## Views

* Never call the model layer directly from a view.
* Never make complex formatting in the views, export the formatting to
  a method in the view helper or the model.
* Mitigate code duplication by using partial templates and layouts.

## Mailers

* Name the mailers `SomethingMailer`. Without the Mailer suffix it
  isn't immediately apparent what's a mailer and which views are
  related to the mailer.
* Provide both HTML and plain-text view templates.
* Enable errors raised on failed mail delivery in your development environment. The errors are disabled by default.

    ```Ruby
    # config/environments/development.rb

    config.action_mailer.raise_delivery_errors = true
    ```

* Provide default settings for the host name.

    ```Ruby
    # config/environments/development.rb
    config.action_mailer.default_url_options = {host: "#{local_ip}:3000"}


    # config/environments/production.rb
    config.action_mailer.default_url_options = {host: 'your_site.com'}

    # in your mailer class
    default_url_options[:host] = 'your_site.com'
    ```

* If you need to use a link to your site in an email, always use the
  `_url`, not `_path` methods. The `_url` methods include the host
  name and the `_path` methods don't.

    ```Ruby
    # wrong
    You can always find more info about this course
    = link_to 'here', url_for(course_path(@course))

    # right
    You can always find more info about this course
    = link_to 'here', url_for(course_url(@course))
    ```

* Format the from and to addresses properly. Use the following format:

    ```Ruby
    # in your mailer class
    default from: 'Your Name <info@your_site.com>'
    ```

* Make sure that the e-mail delivery method for your test environment is set to `test`:

    ```Ruby
    # config/environments/test.rb

    config.action_mailer.delivery_method = :test
    ```

* When sending html emails all styles should be inline, as some mail clients
  have problems with external styles. This however makes them harder to
  maintain and leads to code duplication. There are gems that
  transform the styles and put them in the corresponding html tags.

* Consider sending emails in a background process. Sending emails while
  generating page response should be avoided. It causes delays in loading
  of the page and requests can timeout.

## Bundler
* Remove default comments
* Versioning is discouraged unless a specific version of the gem is required.
* **Do not** run `bundle update` unless for a specific gem.
* Structure Gemfile content in the following order:
  * source
  * Nonstandard logic or modifications
  * Default Rails gems (listed in default order)
  * Nondefault top-level Rails gems (listed alphabetically)
  * Nondefault development Rails gems (listed alphabetically)
  * Nondefault production Rails gems (listed alphabetically)
  * Nondefault test Rails gems (listed alphabetically)

    ```Ruby
    source 'https://rubygems.org'

    eval 'Gemfile.engine'

    gem 'rails', '4.0.0'
    gem 'sqlite3'
    gem 'sass-rails', '~> 4.0.0'
    gem 'uglifier', '>= 1.3.0'
    gem 'coffee-rails', '~> 4.0.0'
    gem 'jquery-rails'
    gem 'turbolinks'
    gem 'jbuilder', '~> 1.2'

    group :doc do
      gem 'sdoc', require: false
    end

    gem 'kaminari'
    gem 'nokogiri'

    group :development do
      gem 'pry'
      gem 'yard'
    end

    group :production do
      gem 'analytics'
      gem 'heroku'
    end

    group :test do
      gem 'rspec'
      gem 'spork'
    end
    ```
