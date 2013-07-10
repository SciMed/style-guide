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
    end

    resources :photos do
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

* Keep the controllers skinny - they should only retrieve data for the
  view layer and shouldn't contain any business logic (all the
  business logic should naturally reside in the model).
* Each controller action should (ideally) invoke only one method other
  than an initial find or new.
* Share no more than two instance variables between a controller and a view.

## Models

* Introduce non-ActiveRecord model classes freely.
* Name the models with meaningful (but short) names without
abbreviations.
* If you need model objects that support ActiveRecord behavior(like
  validation) use the
  [ActiveAttr](https://github.com/cgriego/active_attr) gem.

    ```Ruby
    class Message
      include ActiveAttr::Model

      attribute :name
      attribute :email
      attribute :content
      attribute :priority

      attr_accessible :name, :email, :content

      validates :name, presence: true
      validates :email, format: { with: /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i }
      validates :content, length: { maximum: 500 }
    end
    ```

    For a more complete example refer to the
    [RailsCast on the subject](http://railscasts.com/episodes/326-activeattr).

### ActiveRecord

* Avoid altering ActiveRecord defaults (table names, primary key, etc)
  unless you have a very good reason (like a database that's not under
  your control).

    ```Ruby
    # bad - don't do this if you can modify the schema
    class Transaction < ActiveRecord::Base
      self.table_name = 'order'
      ...
    end
    ```

* Group macro-style methods (`has_many`, `validates`, etc) in the
  beginning of the class definition.

    ```Ruby
    class User < ActiveRecord::Base
      # keep the default scope first (if any)
      default_scope { where(active: true) }

      # constants come up next
      GENDERS = %w(male female)

      # afterwards we put attr related macros
      attr_accessor :formatted_date_of_birth

      attr_accessible :login, :first_name, :last_name, :email, :password

      # followed by association macros
      belongs_to :country

      has_many :authentications, dependent: :destroy

      # and validation macros
      validates :email, presence: true
      validates :username, presence: true
      validates :username, uniqueness: { case_sensitive: false }
      validates :username, format: { with: /\A[A-Za-z][A-Za-z0-9._-]{2,19}\z/ }
      validates :password, format: { with: /\A\S{8,128}\z/, allow_nil: true}

      # next we have callbacks
      before_save :cook
      before_save :update_username_lower

      # other macros (like devise's) should be placed after the callbacks

      ...
    end
    ```

* Prefer `has_many :through` to `has_and_belongs_to_many`. Using `has_many
:through` allows additional attributes and validations on the join model.

    ```Ruby
    # using has_and_belongs_to_many
    class User < ActiveRecord::Base
      has_and_belongs_to_many :groups
    end

    class Group < ActiveRecord::Base
      has_and_belongs_to_many :users
    end

    # prefered way - using has_many :through
    class User < ActiveRecord::Base
      has_many :memberships
      has_many :groups, through: :memberships
    end

    class Membership < ActiveRecord::Base
      belongs_to :user
      belongs_to :group
    end

    class Group < ActiveRecord::Base
      has_many :memberships
      has_many :users, through: :memberships
    end
    ```

* Prefer `self[:attribute]` over `read_attribute(:attribute)`.

    ```Ruby
    # bad
    def amount
      read_attribute(:amount) * 100
    end

    # good
    def amount
      self[:amount] * 100
    end
    ```

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

* Keep custom validators under `lib/validators`.
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

* Wrap named scopes in `lambdas` to initialize them lazily.

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

* When a named scope defined with a lambda and parameters becomes too
complicated, it is preferable to make a class method instead which serves
the same purpose of the named scope and returns an
`ActiveRecord::Relation` object. Arguably you can define even simpler
scopes like this.

    ```Ruby
    class User < ActiveRecord::Base
      def self.with_orders
        joins(:orders).select('distinct(users.id)')
      end
    end
    ```

* Beware of the behavior of the `update_attribute` method. It doesn't
  run the model validations (unlike `update_attributes`) and could easily corrupt the model state.
* Use user-friendly URLs. Show some descriptive attribute of the model in the URL rather than its `id`.
There is more than one way to achieve this:
  * Override the `to_param` method of the model. This method is used by Rails for constructing a URL to the object.
    The default implementation returns the `id` of the record as a String. It could be overridden to include another
    human-readable attribute.

        ```Ruby
        class Person
          def to_param
            "#{id} #{name}".parameterize
          end
        end
        ```

    In order to convert this to a URL-friendly value, `parameterize` should be called on the string. The `id` of the
    object needs to be at the beginning so that it can be found by the `find` method of ActiveRecord.

  * Use the `friendly_id` gem. It allows creation of human-readable URLs by using some descriptive attribute of the model instead of its `id`.

        ```Ruby
        class Person
          extend FriendlyId
          friendly_id :name, use: :slugged
        end
        ```

        Check the [gem documentation](https://github.com/norman/friendly_id) for more information about its usage.

### ActiveResource

* When the response is in a format different from the existing ones (XML and
JSON) or some additional parsing of these formats is necessary,
create your own custom format and use it in the class. The custom format
should implement the following four methods: `extension`, `mime_type`,
`encode` and `decode`.

    ```Ruby
    module ActiveResource
      module Formats
        module Extend
          module CSVFormat
            extend self

            def extension
              'csv'
            end

            def mime_type
              'text/csv'
            end

            def encode(hash, options = nil)
              # Encode the data in the new format and return it
            end

            def decode(csv)
              # Decode the data from the new format and return it
            end
          end
        end
      end
    end

    class User < ActiveResource::Base
      self.format = ActiveResource::Formats::Extend::CSVFormat

      ...
    end
    ```

* If the request should be sent without extension, override the `element_path`
and `collection_path` methods of `ActiveResource::Base` and remove the
extension part.

    ```Ruby
    class User < ActiveResource::Base
      ...

      def self.collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
      end

      def self.element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}/#{URI.parser.escape id.to_s}#{query_string(query_options)}"
      end
    end
    ```

    These methods can be overridden also if any other modifications of the
    URL are needed.

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

* Enforce foreign-key constraints. While ActiveRecord does not support
them natively, there some great third-party gems like
[schema_plus](https://github.com/lomba/schema_plus).

* When writing constructive migrations (adding tables or columns), use
  the new Rails 3.1 way of doing the migrations - use the `change`
  method instead of `up` and `down` methods.


    ```Ruby
    # the old way
    class AddNameToPerson < ActiveRecord::Migration
      def up
        add_column :persons, :name, :string
      end

      def down
        remove_column :person, :name
      end
    end

    # the new prefered way
    class AddNameToPerson < ActiveRecord::Migration
      def change
        add_column :persons, :name, :string
      end
    end
    ```

* Don't use model classes in migrations. The model classes are
constantly evolving and at some point in the future migrations that
used to work might stop, because of changes in the models used.

## Views

* Never call the model layer directly from a view.
* Never make complex formatting in the views, export the formatting to
  a method in the view helper or the model.
* Mitigate code duplication by using partial templates and layouts.
* Add
  [client side validation](https://github.com/bcardarella/client_side_validations)
  for the custom validators. The steps to do this are:
  * Declare a custom validator which extends `ClientSideValidations::Middleware::Base`

        ```Ruby
        module ClientSideValidations::Middleware
          class Email < Base
            def response
              if request.params[:email] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
                self.status = 200
              else
                self.status = 404
              end
              super
            end
          end
        end
        ```

  * Create a new file
    `public/javascripts/rails.validations.custom.js.coffee` and add a
    reference to it in your `application.js.coffee` file:

        ```
        # app/assets/javascripts/application.js.coffee
        #= require rails.validations.custom
        ```

  * Add your client-side validator:

        ```Ruby
        #public/javascripts/rails.validations.custom.js.coffee
        clientSideValidations.validators.remote['email'] = (element, options) ->
          if $.ajax({
            url: '/validators/email.json',
            data: { email: element.val() },
            async: false
          }).status == 404
            return options.message || 'invalid e-mail format'
        ```


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

* Use `smtp.gmail.com` for SMTP server in the development environment
  (unless you have local SMTP server, of course).

    ```Ruby
    # config/environments/development.rb

    config.action_mailer.smtp_settings = {
      address: 'smtp.gmail.com',
      # more settings
    }
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

* The delivery method for development and production should be `smtp`:

    ```Ruby
    # config/environments/development.rb, config/environments/production.rb

    config.action_mailer.delivery_method = :smtp
    ```

* When sending html emails all styles should be inline, as some mail clients
  have problems with external styles. This however makes them harder to
  maintain and leads to code duplication. There are two similar gems that
  transform the styles and put them in the corresponding html tags:
  [premailer-rails3](https://github.com/fphilipe/premailer-rails3) and
  [roadie](https://github.com/Mange/roadie).

* Sending emails while generating page response should be avoided. It causes
  delays in loading of the page and request can timeout if multiple email are
  send. To overcome this emails can be send in background process with the help
  of [delayed_job](https://github.com/tobi/delayed_job) gem.

## Bundler

* Put gems used only for development or testing in the appropriate group in the Gemfile.
* Use only established gems in your projects. If you're contemplating
on including some little-known gem you should do a careful review of
its source code first.
* OS-specific gems will by default result in a constantly changing `Gemfile.lock`
for projects with multiple developers using different operating systems.
Add all OS X specific gems to a `darwin` group in the Gemfile, and all Linux
specific gems to a `linux` group:

    ```Ruby
    # Gemfile
    group :darwin do
      gem 'rb-fsevent'
      gem 'growl'
    end

    group :linux do
      gem 'rb-inotify'
    end
    ```

    To require the appropriate gems in the right environment, add the
    following to `config/application.rb`:

    ```Ruby
    platform = RUBY_PLATFORM.match(/(linux|darwin)/)[0].to_sym
    Bundler.require(platform)
    ```

* Do not remove the `Gemfile.lock` from version control. This is not
  some randomly generated file - it makes sure that all of your team
  members get the same gem versions when they do a `bundle install`.

# Further Reading

There are a few excellent resources on Rails style, that you should
consider if you have time to spare:

* [The Rails 3 Way](http://www.amazon.com/Rails-Way-Addison-Wesley-Professional-Ruby/dp/0321601661)
* [Ruby on Rails Guides](http://guides.rubyonrails.org/)
* [The RSpec Book](http://pragprog.com/book/achbd/the-rspec-book)
* [The Cucumber Book](http://pragprog.com/book/hwcuc/the-cucumber-book)
* [Everyday Rails Testing with RSpec](https://leanpub.com/everydayrailsrspec)

# Contributing

Nothing written in this guide is set in stone. It's my desire to work
together with everyone interested in Rails coding style, so that we could
ultimately create a resource that will be beneficial to the entire Ruby
community.

Feel free to open tickets or send pull requests with improvements. Thanks in
advance for your help!

# License

![Creative Commons License](http://i.creativecommons.org/l/by/3.0/88x31.png)
This work is licensed under a [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/deed.en_US)

# Spread the Word

A community-driven style guide is of little use to a community that
doesn't know about its existence. Tweet about the guide, share it with
your friends and colleagues. Every comment, suggestion or opinion we
get makes the guide just a little bit better. And we want to have the
best possible guide, don't we?

Cheers,<br/>
[Bozhidar](https://twitter.com/bbatsov)
