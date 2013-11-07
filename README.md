# ❀ A Highly Fashionable Style Guide

This guide provides a set of best practices and style prescriptions
for application development based on SciMed Solutions' years
of development experience.

#### Table of Contents

* [Rails](#rails)
* [Ruby](#ruby)
* [JavaScript](#javascript)
* [CSS](#css)
* [HTML](#html)

# Rails

#### Routing

* Try to avoid adding non RESTful routes to a resource.
* Avoid more than 1 level of resource nesting. [see example](samples/nested_routes.md)
* Do not use the `match` wildcard route matcher

#### Controllers

* Structure Controller content **[in the following order](samples/controller.md)**:
* Try to avoid adding non RESTful actions to a resource.
* Storing anything in session is discouraged.
* Keep controllers skeletal - they shouldn't contain business logic
* Place non RESTful actions above RESTful actions in the controller.
* Consider adding a resource if a controller has more than 2 non default actions [see example](samples/restful_controller.md)
* Each controller action should ideally invoke only one method other than find or new
* Share no more than two instance variables between a controller and a view.
* Remove generated `respond_to` blocks from controller actions unless needed.
* Remove generated comments on Controller actions.

#### Models

* Structure model content **[in the following order](samples/model.md)**:
* Using non-ActiveRecord models is encouraged.
* Do not place non-ActiveRecord models in lib, place them in the models.
* Only use the lib directory for code that is not within the application's domain model.
* Consider vendoring any code placed in the lib directory as a gem.
* *** TODO: add directory naming conventions to group models, since there can be
  several files in the models directory.
* Do not camelCase acronyms in class names. [see example](samples/camelcasing.md)
* Avoid adding default_scope.
* Avoid adding callbacks in favor of [an object decorator](samples/callback.md).
* Avoid adding callbacks that modify other models.
* Consider using methods instead of constants. Methods are easier to stub, test, and mark private.
* Use of `class << self` is discouraged in ActiveRecord models.
* Use of `has_and_belongs_to_many` is *strongly* discouraged.  Use `has_many :through` instead.
* Use `validates` instead of the `validates_*_of` method. [see example](samples/validates.md)
* Use a Validator object for custom validations [see example](samples/validator.md)
* Keep custom validators under `models/validators`.
* Use named scopes.
* Use of `update_attribute` is discouraged. (Rails 3-)

#### Views

* Never call the model layer directly from a view.
* Never make complex formatting in the views, export the formatting to
  a method in the view helper or the model.
* Avoid using DRY principles to reduce duplication of code that is visually
  the same, rather than essentially the same. Code should not be made DRY if
  the business motivation behind duplicated code differs between cases. Please see
  [In Defense of Copy Paste](http://zacharyvoase.com/2013/02/08/copypasta/)
  for more information. While this is applicable in all forms of code, this
  is particularly problematic in view code.

#### Migrations

* **Do Not** use `rake db:migrate` to build the database schema for a new application.
* *Use* `rake db:schema:load` and `rake db:seed` to build the database schema.
* Keep the `schema.rb` (or `structure.sql`) under version control.
* Use `rake db:test:prepare` to update the schema of the test database.
* Enforce default values in migrations instead of in the application layer.

#### Seeds

* Avoid developing against production data dumps.
* Create and update seeds as you develop.
* Seeds should mirror the current state of the app and provide enough data to access and test all features of the application.
* Data needed for all environments, including production, should be in seeds.
* Other seeds should be kept in the `db/seeds` directory.
* Rake tasks should be created in the db:seed namespace for development data.
* Use FactoryGirl factories and Forgery to seed development data.
* Test the seeds in your test suite, or on CI (based on time).
* Create a rails generator that creates a seed file when you create a new model. Opt
  out of creating seeds, instead of opting in.
* Teardown and rebuild your database regularly.

#### Mailers

* Suffix mailer names with `Mailer`
* Provide both HTML and plain-text view templates.
* If you need to use a link in an email, always use the `_url`, not `_path` methods.
* Format the from and to addresses as `Your Name <info@your_site.com>`.
* Consider sending emails in a background process to prevent delays page load.

#### Bundler
* Structure Gemfile content **[in the following order](samples/gemfile.md)**:
* **Do not** run `bundle update` unless for a specific gem.
* Remove default comments
* Versioning is discouraged unless a specific version of the gem is required.

# Ruby
Move along, nothing to see here yet.

# JavaScript
Move along, nothing to see here yet.

# CSS
Move along, nothing to see here yet.

# HTML
Move along, nothing to see here yet.

