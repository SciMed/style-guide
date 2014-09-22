# :high_heel: A Highly Fashionable Style Guide

This guide provides a set of best practices and style prescriptions
for application development based on SciMed Solutions' years
of development experience.

#### The Runway

* [Ruby](#ruby)
* [Rails](#rails)
* [JavaScript](#javascript)
* [SCSS](#scss)
* [HTML](#html)

# Ruby
* Encapsulate generic functionality into separate libraries and gems
* Write integration tests using TDD/BDD
* Adhere to Rubocop when possible
* Adhere to Rails Best Practices when possible
* Define methods private by calling "private :my_method" directly after the end of the method.
* Feel free to use libraries which add little bits of helpful functionality and don't take over the application or require all developers to learn a new skillset. If you are thinking of using a library or framework that will take over the application or require other developers to spend time learning it, be sure to discuss with everyone before using it in your project.

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
* Pretty much all of the application's code should stay out of lib. Think of lib as a place to put components that are generalized enought that they could be used in other applications. But then why not make those things into gems?
* Consider vendoring any code placed in the lib directory as a gem.
* Organize models into `app/models/`: `services`, `concerns`, `strategies`, `decorators`, `validators`.
* *Even better*: Organize models into gems or namespaces
* Do not camelCase acronyms in class names. [see example](samples/camelcasing.md)
* Avoid adding `default_scope`.
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

* Accessing database models or the database from the view breaks the separation that is the goal of MVC. It would be best to build presenter objects which store the data needed for the view. (In some cases this may not be worthwhile in practice, but it is good to consider the dependencies being built between the view and the database/models.)
* Never make complex formatting in the views, export the formatting to
  a presenter object.
* Avoid using DRY principles to reduce duplication of code that is visually
  the same, rather than essentially the same. Code should not be made DRY if
  the business motivation behind duplicated code differs between cases. Please see
  [In Defense of Copy Paste](http://zacharyvoase.com/2013/02/08/copypasta/)
  for more information. While this is applicable in all forms of code, this
  is particularly problematic in view code.
* Don't make partials for the fun of it. Make partials when it makes sense to have partials around. (It's no fun digging through 10 layers of partials if they don't have some benefit).

#### Migrations

* Both schema.rb and migration files should be maintained so that developers can migrate from scratch or load the schema.
* When setting up a new application, use `rake db:schema:load` and `rake db:seed` unless you have a good reason to run migrations from scratch.
* Keep the `schema.rb` (or `structure.sql`) up to date and under version control.
* Migrations should define any classes that they use. (If the class is deleted in the future the migrations should still be able to run).
* For rails 1, 2, and 3 applications use `rake db:test:prepare` to update the schema of the test database. (This is deprecated in Rails 4).
* Use those database features! Enforce default values, null contraints, uniqueness, etc in the database (in migrations instead) of only in the application layer. (The database can avoid race conditions, is faster and more reliable).
* When you create a new migration, run it both UP AND DOWN before commiting the change.
* Prefer using "change" in migrations to writing individual "up" and "down" methods when possible.

#### Seeds

* Avoid developing against production data dumps.
* Create and update seeds as you develop.
* Seeds should mirror the current state of the app and provide enough data to access and test all features of the application.
* Data needed for all environments, including production, should be in seeds.
* Other seeds should be kept in the `db/seeds` directory.
* Rake tasks should be created in the db:seed namespace for development data.
* Use FactoryGirl factories to seed development data.
* Test the seeds in your test suite, or on CI (based on time).
* Create a rails generator that creates a seed file when you create a new model. Opt
  out of creating seeds, instead of opting in.
* Teardown and rebuild your database regularly.

#### Mailers

* Suffix mailer names with `Mailer`
* Provide both HTML and plain-text view templates.
* If you need to use a link in an email, always use the `_url`, not `_path` methods.
* Format the from and to addresses as `Your Name <info@your_site.com>`.
* Consider sending emails in a background process to prevent page load delays.
* When sending email to multiple users, send an individual email to each person rather than having multiple recipients in one email. (This increases security because users can't see each other's addresses, and makes it easier to handle errors with invalid email addresses)
* Log when emails are sent and when they fail to send.

#### Bundler
* Structure Gemfile content **[in the following order](samples/gemfile.md)**:
* **Do not** run `bundle update` unless for a specific gem. (Updating all of the gems without paying attention could unintentionally break things)
* Remove default comments
* Versioning is discouraged unless a specific version of the gem is required. (But keep an eye out for breaking things when gem versions update!)

# JavaScript
* Use CoffeeScript over JavaScript
* Use a package manager like Bower for installing dependencies? (This item is questionable as some people raised issues with using Bower with Rails. We can discuss further.)
* Prefer a JavaScript framework over vanilla JavaScript. (This means don't roll your own custom event library or other things that exist out there. But do make sure the company is on board with any new libraries that are used before including them in a project)
* Use IIFE or Object Literal notation
* Separate responsibilities of vanilla JavaScript into separate entities.
* Query DOM elements using 'js-' or 'data-' attributes instead of CSS classes
* Do not rely on or store data in the DOM. (This is particularly true from a security stand point. Do not put secure or sensitive information in the DOM. For example do not have a hidden field with a SSN, or that determines whether someone is an admin).

# SCSS
* Order styles alphabetically.
* Use the SCSS `@import` declaration to require stylesheets vs `*= require`.
* Use the `asset-url` helper for images and fonts. [see example](samples/asset_url.md)
* Lowercase and dasherize class names.
* Avoid the `>` direct descendant selector when the descendant is a tag [see example](samples/descendant.md)
* Avoid ID selectors
* Use SCSS variables
* Generic naming is favored over domain-driven naming (e.g. `.aside` vs `.cytometry`)
* Prefer naming elements by content type over visual traits (e.g. `.aside` vs `.left-side-bar`)
* Encapsulate framework and grid system class names into semantic styles [see example](samples/mixins.md)
* Use `box-sizing: border-box;` (Whenever browsers support it, this allows you to define the size of actual boxes, rather than the size before padding and borders are added. Generally works for IE8+).
* Consider the organizational advantages of SMACSS.

# HTML
* Do not use tables for presentational layout. *That's sooo 1999.*
* Do **not *not*** use tables for tabular data *That's sooo 2001.*
* Do not use `<image>` tags for decorative content. [see example](samples/images.md)
* Use of presentational markup is discouraged (<b>, <i>, <blink>, etc)
* Do not name tags if they don't need to be named
* Do not directly apply framework and grid system class names. [see example](samples/mixins.md)
* Use of XHTML markup is discouraged e.g. `<br />`
* Use layout tags (e.g. `<section>`, `<header>`, `<footer>`, `<aside>`) You are not bound to only having one `<header>` or one `<footer>` tag on a page. (Note that you can have only one <main> tag however).

