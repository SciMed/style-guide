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

* In Rails 3 and below, never use the legacy wildcard controller routes. This
  route will make all actions in every controller accessible via POST requests.

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
* Structure Controller content [in the following order](samples/controller.rb):
  * Module extend/include
  * Third party macros (devise, paperclip)
  * `*_filter` or `*_action` macros in chronological order.
  * Nondefault controller actions
  * Default controller actions
  * Private methods

## Models

* Using non-ActiveRecord models is encouraged.
* Do not place non-ActiveRecord models in lib, place them in the models
  directory. The lib directory should only be used for code that is not
  within the applications domain model. Consider placing all other code
  in the models or initializers directory. Furthermore, consider vendoring
  any code placed in the lib directory as a gem.
* *** TODO: add directory naming conventions to group models, since there can be
  several files in the models directory.
* Name the models with meaningful, succinct names without
  abbreviations. Known acronyms are acceptable.
* Do not camelCase acronyms in class names. Ruby has built-in support for
  upcased class names.

  ```Ruby
  # BAD
  class HttpInterface
  end

  # GOOD
  class HTTPInterface
  end
  ```

### ActiveRecord

* Avoid adding default_scope.
* Avoid adding callbacks in favor of [an object decorator](samples/callback.rb).
* Avoid adding callbacks if they are modifying other models.
* Group macro-style methods (`has_many`, `validates`, etc) in the
  beginning of the class definition.
* Consider using a methods instead of constants. Methods are easier
  to stub and test. Methods can also be marked as private/protected.
* Structure model content [in the following order](samples/model.rb):
  * Module extend/include
  * set_table_name, set_primary_key, default_scope
  * Third party macros (devise, paperclip)
  * Constants
  * attr_accessible
  * Callbacks in chronological order.
  * validate then validates macros in alphabetical order
  * attr_accesor and delegate macros
  * associations in alphabetical order
  * accepts_nested_attributes_for
  * scopes
  * Public then private methods
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
      validates :email, format: { with: /@/i }
    end

    # good
    class EmailValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors[attribute] << 'is not a valid email' unless value =~ /@/i
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

* **Do Not** use `rake db:migrate` to build the database schema for a new application.
  Migrations are intended to be run from a certain point in time for existing production
  systems and are not intended to always work. Use `rake db:schema:load` and `rake db:seed`
  to build the database schema, this is faster and will not cause unintended errors.
* Keep the `schema.rb` (or `structure.sql`) under version control.
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
* Older migrations should be periodically archived in `db/migrate/archived_migrations`

## Views

* Never call the model layer directly from a view.
* Never make complex formatting in the views, export the formatting to
  a method in the view helper or the model.
* Avoid using DRY principles to reduce duplication of code that is visually
  the same, rather than essentially the same. Code should not be made DRY if
  the business motivation behind duplicated code differs between cases. Please see
  [In Defense of Copy Paste](http://zacharyvoase.com/2013/02/08/copypasta/)
  for more information. While this is applicable in all forms of code, this
  is particularly problematic in view code.

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
* Structure Gemfile content [in the following order](samples/gemfile.rb):
  * source
  * Nonstandard modifications
  * Default Rails gems (listed in default order)
  * Nondefault gems and gem groups (listed alphabetically)
  * development, production, and test groups (listed alphabetically)
