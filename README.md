# :high_heel: A Highly Fashionable Style Guide

This guide provides a set of best practices and style prescriptions
for application development based on SciMed Solutions' years
of development experience.

**Read this before making any changes to the style guide**

If you make any changes to the style guide, please clearly describe the logic that led to the decision clearly in your commit message. Developers who are not privy to the initial discussion will need to understand why the decision was made in order to evaluate whether the decision is still relevant and whether it is pertinent to their current situation.

#### The Runway

* [Ruby](#ruby)
* [Rails](#rails)
* [JavaScript](#javascript)
* [JSON](#json)
* [Logging](#logging)
* [SCSS](#scss)
* [HTML](#html)
* [RSpec](#rspec)
* [SQL](#sql)

# Ruby
* Encapsulate generic functionality into separate libraries and gems.
* Write integration tests using TDD/BDD.
* Adhere to Rubocop when possible.
  * See our default [`.rubocop.yml`](./.rubocop.yml).
* Adhere to Rails Best Practices when possible.
* Freeze constants in their definitions to prevent constant mutation.
  * Example: `ITEMS = %w(banana apple cherry).freeze`
* Never `rescue` or `fail`/`raise` a generic `Exception`. Instead, `rescue`/`fail`/`raise` a specific type of `Exception`.
* Mark methods as private by calling `private def foo` when using recent Ruby versions (> 2.1.0). For earlier versions, mark methods as private by calling `private :my_method` directly after the end of the method.
* Keep private methods clustered together at the end of the file.
* Feel free to use libraries which add little bits of helpful functionality and don't take over the application or require all developers to learn a new skillset. If you are thinking of using a library or framework that will take over the application or require other developers to spend time learning it, be sure to discuss with everyone before using it in your project.
* Write arrays on a single line when they are less than 80 characters long. Otherwise, write them as one line per item.
  * [Example](samples/arrays.md)

#### Documentation
* Document methods using [Yard](http://yardoc.org/) style documentation.
  * Example:
  ```ruby
  # @param [Array<String>] names The names that will be joined
  # @return [String] a concatenated list of names
  def foo(names)
    ...
    list_of_names
  end
  ```

# Rails

#### Routing

* Avoid more than 1 level of resource nesting.
  * [Example](samples/nested_routes.md)
* Do not use the `match` wildcard route matcher.

#### Controllers

* Structure Controller content **[in this order](samples/controller.md)**.
* Try to avoid adding non RESTful actions to a resource.
* Storing anything in session is discouraged.
  * This can be a security risk unless done carefully. This also makes the browser part of the current state of the application, allowing things to get out of whack. For example keeping the current working record in the session causes problems if users try to use the application with more than one tab or window.
* Keep controllers skeletal—they shouldn't contain business logic.
* Place non RESTful actions above RESTful actions in the controller.
* Consider adding a resource if a controller has more than two non-default actions.
  * [Example](samples/restful_controller.md)
* Each controller action should ideally invoke only one method other than `find` or `new`.
* Share no more than two instance variables between a controller and a view.
* Remove generated `respond_to` blocks from controller actions unless needed.
* Remove generated comments on controller actions.
* Keep empty controller action definitions.

#### Models

* Structure model content **[in this order](samples/model.md)**.
* Using non-ActiveRecord models is encouraged.
* Do not place non-ActiveRecord models in `lib/`, place them in `app/models/`.
* Pretty much all of the application's code should stay out of `lib/`. Think of `lib/` as a place to put components that are generalized enough that they could be used in other applications (but then why not make those things into gems?).
* Consider vendoring any code placed in the `lib/` directory as a gem.
* Organize objects into `app/`: `concerns/`, `decorators/`, `modules/`, `services/`, `strategies/`, `validators/`.
* *Even better*: organize models into gems or namespaces.
* Do not camelCase acronyms in class names.
  * [Example](samples/camelcasing.md)
* Avoid adding `default_scope`.
* Avoid adding callbacks in favor of [an object decorator](samples/callback.md).
* Avoid adding callbacks that modify other models.
* Consider using methods instead of constants. Methods are easier to stub, test, and mark private.
* Use of `class << self` is discouraged in ActiveRecord models.
* Use of `has_and_belongs_to_many` is *strongly* discouraged.  Use `has_many :through` instead.
* Use `validates` instead of the `validates_*_of` method.
  * [Example](samples/validates.md)
* Use a Validator object for custom validations.
  * [Example](samples/validator.md)
* Keep custom validators under `app/validators`.
* Use scopes.
* Use of `update_attribute` is discouraged because it skips validations. Note that it will also persist changes to any other dirty attributes on your model as well, not just the attribute that you are trying to update.
* Use of `update_column`, `update_columns`, and `update_all` are discouraged because they skip validations and callbacks. However, if you do not need validations or callbacks, `update_column` is preferred over update_attribute because it is easier to remember that it does not run validations.
* Custom Inflectors: It can be tough to decide whether to use customer inflectors for pluralization. The most important piece is to make sure that user facing text is pluralized correctly. You should be able to handle this with Internationalization alone. If you feel it will make future developers' lives easier, you can also write a custom inflector so that we can refer to the model correctly in Rails.
  * [Internationalization example](samples/plural_i18n.md)
  * [Custom inflector example](samples/custom_inflector.md)
* When accessing associations through other associations, use `has_many` or `has_one` `through` rather than a delegation or a custom method **when all target objects in the associations are persisted**. Use delegations or custom methods **when there is useful data that is not yet persisted**. Keeping the data in associations allows preloading to prevent n+1 queries and ensures that more processing is done via SQL than Ruby, which is more performant. Unfortunately, associations `through` other associations will not see non-persisted objects.

#### Views

* Accessing database models or the database from the view breaks the separation that is the goal of MVC. It would be best to build presenter objects which store the data needed for the view.
  * In some cases this may not be worthwhile in practice, but it is good to consider the dependencies being built between the view and the database/models.
* Never make complex formatting in the views, moving the formatting to
  a presenter object. For example, if you are displaying a schedule, do not put the logic for grouping events into days in the view.
* Avoid using DRY principles to reduce duplication of code that is visually
  the same, rather than essentially the same. Code should not be made DRY if
  the business motivation behind duplicated code differs between cases. Please see
  [In Defense of Copy Paste](http://zacharyvoase.com/2013/02/08/copypasta/)
  for more information. While this is applicable in all forms of code, this
  is particularly problematic in view code.
* Put data attributes in a hash when using a view helper.
  * Example: `f.input :foo, data: { input_method: :foo }`
  * Note that underscores in keys will be translated to dashes when rendered to HTML. The previous example's data attribute will render as `data-input-method="foo"`.
* Prefer `f.collection_select :foo` over `f.select :foo, options_from_collection_for_select` when possible.
  * Note that `collection_select` sets the selected value by default whereas `options_from_collection_for_select` needs the selected value to be specified as a parameter.
* Use Rails helper for labels wherever possible.
* Ensure that label tags connect with the correct form input.
* Don't make partials for the fun of it. Make partials when it makes sense to have partials around. (It's no fun digging through 10 layers of partials if they don't have some benefit). It is discouraged to have partials more than 2 levels deep.
* For new projects, use ERB as the templating engine. For old projects, use whatever is already in place.
* Try to avoid multiline embedded Ruby—it's likely indicative of logic that should be extracted to a presenter, service object, or helper. When necessary, use the following format:
```
<%
  some_long_ruby
  some_more_long_ruby
%>
```

#### Migrations

* Both `schema.rb` and migration files should be maintained so that developers can migrate from scratch or load the schema.
* When setting up a new application, use `rake db:schema:load` and `rake db:seed` unless you have a good reason to run migrations from scratch.
* Keep the `schema.rb` (or `structure.sql`) up to date and under version control.
* Migrations should define any classes that they use (if the class is deleted in the future, the migrations should still be able to run).
* Use those database features! Enforce default values, null constraints, uniqueness, etc in the database (via migrations) instead of only in the application layer, as the database can avoid race conditions and is faster and more reliable.
* If you have not-null constraints be sure to do dependent destroy on the parent. Otherwise you will get invalid query exceptions when things are deleted.
* When you create a new migration, run it both `up` ***and*** `down` before committing the change (`rake db:migrate:redo` will run the very last migration down and then up again).
* Prefer using `change` in migrations to writing individual `up` and `down` methods when possible.
* Make sure to update seeds/factories when adding columns (particularly those with validations) or tables.
* If you are modifying data in a migration be sure to call two methods at the beginning of the migration. If you don't reset the column information then some data could be silently lost instead of saved. Also, Rails will only reset column information once even if you call it multiple times, which is why the `schema_cache` needs to be cleared first.

```ruby
Model.connection.schema_cache.clear!
Model.reset_column_information
```

#### Seeds

* Avoid relying on production database dumps for development. Make sure there are reliable seeds so that future developers can get up and running and access all features quickly.
* Create and update seeds as you develop.
* Seeds should mirror the current state of the app and provide enough data to access and test all features of the application.
* Data needed for all environments, including production, should be in seeds.
* Other seeds should be kept in the `db/seeds` directory.
* Rake tasks should be created in the `db:seed` namespace for development data.
* Use FactoryGirl/Bot factories to seed development data.
* Test the seeds in your test suite or on CI (based on time).
* Create a Rails generator that creates a seed file when you create a new model. Opt
  out of creating seeds, instead of opting in.
* Tear down and rebuild your database regularly.

#### Mailers

* Suffix mailer names with `Mailer`.
* Provide both HTML and plain-text view templates.
* If you need to use a link in an email, always use the `_url`, not `_path` methods.
* Format the from and to addresses as `Your Name <info@your_site.com>`.
* Consider sending emails in a background process to prevent page load delays.
* When sending email to multiple users, send an individual email to each person rather than having multiple recipients in one email.
  * This increases security because users can't see each other's addresses and makes it easier to handle errors with invalid email addresses.
* Log when emails are sent and when they fail to send.

#### Time

* Use `Time.zone.now` in lieu of `Time.now` or `Time.current` when referencing the current time. See Issue #11 for more information.
* Use `Time.zone.today` to access the current date, `Time.zone.yesterday` to access yesterday's date (Rails 4.1.8+), and `Time.zone.tomorrow` (Rails 4.1.8+) to access tomorrow's date.

#### Bundler
* Structure Gemfile content **[in this order](samples/gemfile.md)**.
* **Do not** run `bundle update` unless for a specific gem. Updating all of the gems without paying attention could unintentionally break things.
* Remove default comments.
* Versioning is discouraged unless a specific version of the gem is required (but keep an eye out for breaking things when gem versions update!).

#### Localization/Internationalization (i18n) configuration

* Consider using localization/internationalization config files to encapsulate customer-facing strings such as error messages when:
  * the text is likely to change frequently OR
  * the text is a template that is used in multiple places (i.e. to keep the code DRY). Note that i18n supports [variable interpolation](http://guides.rubyonrails.org/i18n.html#passing-variables-to-translations).

# JavaScript

## General conventions
* Query DOM elements using `data-` attributes instead of CSS classes. CSS classes should be used exclusively for styling, whereas `data-` attributes should be used exclusively for JavaScript querying.
* Do not rely on or store data in the DOM.
  * This is particularly true from a security stand point. Do not put secure or sensitive information in the DOM. For example, do not have a hidden field with a SSN or that determines whether someone is an admin.
* Always prefix jQuery variables with `$`
  * Example: `$finder = $('.finder')`
* Always prefix Immutable.js variables with `$$`
  * Example: `$$state`
* When short-circuiting an event listener, explicitly call `event.stopPropogation` and/or `event.preventDefault` as appropriate rather than relying on `return false`.
  * This is because `return false` has different effects in different contexts (see the discussion [here](https://stackoverflow.com/a/4379435)).

## ES6
All new apps should:

* Aim to support at least ES6/ES2015.
* Use Babel to transpile to ES5 if called for by browser support requirements.
* Use webpack for bundling and module resolution.
* Use `yarn` for npm package management.

The most straightforward way to meet these requirement is by installing and configuring the `webpacker` gem.

Prefer the ES6 `import` syntax when possible, but you can use `require` for npm packages where needed.

### eslint

Each project supporting ES6 should use eslint, using a `.eslintrc` file, as in [this example](./.eslintrc) (note that the `env` and `globals` values may vary by project).

Eslint can by run on the command line with `yarn eslint` if the following is added to your project's `package.json`:

```
{
  "scripts": {
    "eslint": "eslint --format codeframe app/client"
  }
}
```

Eslint should be run as part of your project's default rake task.

## CoffeeScript
Many of our legacy apps include CoffeeScript code for JS functionality. In these cases, come to a consensus within the project team about whether to install the `webpacker` gem to support modern JS or to add any new functionality in CoffeeScript.

When using CoffeeScript:

* Namespace JavaScript objects for related chunks of functionality (Components, Engines, etc...).
  * [Example](samples/js_namespace.md)
* Use JS classes and encapsulation (e.g., IIFE or Object Literal notation) wherever possible.
  * [Class example](samples/js_class.md)
  * [Encapsulation example](samples/js_encapsulation.md)
* Prefer a JavaScript framework over vanilla JavaScript.
  * This means don't roll your own custom event library or other things that exist out there, but do make sure the company is on board with any new libraries that are used before including them in a project.
* Separate responsibilities of vanilla JavaScript into separate entities.
* CoffeeScript file extensions should not include `.js` where possible. Prefer `foo.coffee` to `foo.js.coffee.`
* For ternary operations in CoffeeScript, prefer `if foo then bar else baz` (the `? :` syntax has surprising behavior).
* In applications that are not using ReactJS, prefer JS templating libraries (Handlebars, Mustache) to rolling your own over-complicated JS.

## React
Use React when building complex, stateful UIs.

### Technology Stack
* Use Redux when using React if building something stateful or at least moderately complex.
* Use ES6.
* Use Babel to transpile ES6.
* Use WebPack to build JS artifacts.
* Use yarn for dependency management.
* Use ImmutableJS for the state tree.

### Redux
* Use selectors to read the state tree.
  * [Example](samples/redux_selectors.js.md)
* Always test your selectors.
* Put selectors in the same file as the reducers for the same part of the state tree.

### Testing
* Use the setup function pattern.
  * [Example](samples/js_testing_setup_function.js.md)
* Use reusable setup functions for building the state tree.
  * [Example](samples/js_testing_setup_state.js.md)
* Developers have found the following tools useful in testing, but conventions are still being established:
  - [mocha](https://github.com/mochajs/mocha) (testing framework)
  - [jest](https://github.com/facebook/jest) (alternative testing framework)
  - [chai](https://github.com/chaijs/chai) (BDD)
  - [sinon](https://github.com/sinonjs/sinon) (spies, stubs, mocks)
  - [enzyme](https://github.com/airbnb/enzyme) (Airbnb test utils)
  - [babel-plugin-rewire](https://github.com/speedskater/babel-plugin-rewire) (rewire dependencies; note that regular rewire will not work for webpack projects)
  - [fetch-mock](https://github.com/wheresrhys/fetch-mock) (mocks the global fetch function)
  - [jsdom](https://github.com/jsdom/jsdom) (server-side DOM implementation)

# JSON
* If you are designing a JSON API, consider conforming to the [JSON API specification](http://jsonapi.org/format/). Also, it is generally considered good practice to keep your JSON structure as shallow as possible.
* Test the schema of JSON generated by your app.
  * Create a JSON schema according to the documentation provided [here](http://json-schema.org/).
  * Check your schema's validity using tools [like this one](http://www.jsonschemavalidator.net/).
  * Add examples to your specs to check JSON generated by your app against the appropriate schema.  The approach [described by Thoughtbot](https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher) using [the json-schema gem](https://github.com/ruby-json-schema/json-schema) has proven successful.

# Logging
* When rescuing errors, log the error message and backtrace similarly to the
  following:

  ```ruby
  rescue SomeError => e
    ExceptionLogger.log_error(e)
    # custom error handling behavior
  end

  class ExceptionLogger
    def self.log_error(e)
      Rails.logger.error("ERROR: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
  ```

* When avoiding this logging (due to performance, for example), add a comment to
  the `rescue` block that informs future developers why logging is not
  occurring.

# SCSS
* See [this example](samples/scss.md) for whitespace usage.
* Use agreed-upon CSS framework (e.g. [semantic-ui](https://github.com/doabit/semantic-ui-sass)) where possible.
* Order styles alphabetically within a selector.
* Use the SCSS `@import` declaration to require stylesheets vs `*= require`.
* Imported SASS module filenames should begin with an underscore and end with `.scss` only.
  * Example: `_mystyles.scss`
* Use the `asset-url` helper for images and fonts.
  * [Example](samples/asset_url.md)
  * Note that if you use any of the Ruby helpers, the file name requires `.erb` at the end of the file name (e.g. `my_styles.scss.erb`).
* Lowercase and dasherize class names.
* Avoid the `>` direct descendant selector when the descendant is a tag.
  * [Example](samples/descendant.md)
* Avoid ID selectors.
* Use SCSS variables (for example, colors are often used in multiple places).
* Generic naming is favored over domain-driven naming (e.g. `.aside` vs `.cytometry`).
* Prefer naming elements by content type over visual traits (e.g. `.aside` vs `.left-side-bar`).
* Encapsulate framework and grid system class names into semantic styles.
  * [Example](samples/mixins.md)
* Use `box-sizing: border-box;`.
  * Whenever browsers support it, this allows you to define the size of actual boxes, rather than the size before padding and borders are added. Generally works for IE8+.
* Write out the full hex code in uppercase.
  * Example: `#AAAAAA` instead of `#aaa`.
* Avoid meta-programming classes.
* SASS file extensions should not include `.css` where possible. Prefer `foo.scss` to `foo.css.scss`.
* Prefer `.scss` over `.sass`.
* Follow [SMACSS guidelines](https://smacss.com/book/categorizing) for CSS organization (Base, Layout, Module, State, Theme).
* Avoid model-specific CSS.
* Always use a CSS reset. If the CSS framework being used does not provide one, consider using [normalize-rails](https://github.com/markmcconachie/normalize-rails).

# HTML
* Do not use tables for presentational layout. *That's sooo 1999.*
* Do **not *not*** use tables for tabular data *That's sooo 2001.*
* Do not use `<image>` tags for decorative content.
  * [Example](samples/images.md)
* Use of presentational markup is discouraged (`<b>`, `<i>`, `<blink>`, etc).
* Do not name tags if they don't need to be named.
* Do not directly apply framework and grid system class names.
  * [Example](samples/mixins.md)
* Use of XHTML markup is discouraged, e.g. `<br />`.
* Use layout tags (e.g. `<section>`, `<header>`, `<footer>`, `<aside>`).
  * Note that you are _not_ bound to have only one `<header>` or one `<footer>` tag on a page, but you can only have one `<main>` tag.
* Put the JavaScript includes in the bottom of your page, not in the top of the page.
* Modals should be in a partial suffixed with `_modal.html.erb`.
* Double-quote raw HTML attributes.
  * Example: `<i id="foo"></i>`

# RSpec

#### General
* Adhere to Rubocop [(rubocop-rspec)](https://github.com/nevir/rubocop-rspec) when possible.
  * See our default [`.rubocop.yml`](./.rubocop.yml).
* Avoid incidental state when setting up expectations.
  * [Example](samples/specs/incidental_state.md)
* Do not write iterators to generate tests; they make debugging more difficult (all of the tests share line numbers and the `it` description block). Or consider printing a custom error message to give more information about which test is failing.
  * It's okay not to be DRY if repetition of code improves readability.
  * [Example](samples/specs/iterators.md)
* Use factories rather than fixtures.
* Use linting with FactoryGirl/Bot.
* Use `described_class` rather than the class name inside the top-level describe block.
  * [Example](samples/specs/described_class.md)
* Avoid redefining major parts of the application in tests. For example, don't re-define `Rails.development?`.
* Follow the whitespace guide [here](https://github.com/SciMed/style-guide/blob/master/samples/specs/whitespace.md).

#### What to test
* It would be best to test all possible paths through a method, including edge cases.
* Prefer checking exception type over checking a specific error message.
* Use shared examples to test common behavior, but avoid including tests that take a long time to execute.
* Use [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) for testing validations, associations, and delegations in models.
* Prefer testing complicated scopes using an integration test that confirms the expected behavior against persisted records.
* Extract complicated scopes into a QueryBuilder object for easier unit-testing.

#### Mocking and stubbing

* Prefer "verifying" doubles when mocking (e.g. `instance_double`).
  * [Example](samples/specs/instance_double.md)
* Use `let` blocks for assignment instead of `before(:each)` (`let` blocks are lazily evaluated).
* Stub all external connections (HTTP, FTP, etc).
* In controllers, mock models and stub their methods.
* Prefer writing integration tests over controller tests.

#### Expectation syntax
* Favor new syntax (on new projects, use RSpec 3.0+), e.g. favor `expect` over `should` on RSpec 2.11+.
  * [Example](samples/specs/expectation_syntax.md)

#### Description blocks

* Always provide a description string to `it` blocks unless the block contains a [Shoulda Matcher](http://matchers.shoulda.io/) expectation.
* For consistency, use single quotes unless double quotes are needed.
* Keep the full spec description as grammatically correct as possible.
  * [Example](samples/specs/full_description.md)
* Format `describe` block descriptions for class methods as `'.some_class_method_name'` and for instance methods as `'#some_instance_method_name'`.
* Begin `it` block descriptions with `'returns'` or some other verb that describes the functionality (third person, present tense) rather than `'should'`.
  * [Example](samples/specs/it_block_description.md)
* Begin `context` blocks with `having` or `when`.
* Avoid conditionals in `it` block descriptions. Instead, use `context` blocks to organize different states.
  * [Example](samples/specs/conditional_block_description.md)
* Prefer using only one expectation per `it` block, particularly for unit tests.
  * If setup is expensive, it may be reasonable to use multiple expectations in a single `it` block.

#### Capybara
* Prefer using `describe`, `context`, and `it` instead of `feature` and `scenario`.
* Take care to not use brittle selectors.

# Documentation
* Keep the README in the project root directory.
* Use markdown in the `docs/` directory.
* Keep the README up-to-date, useful, and accurate.
* When a new medium or large feature gets added, add a paragraph or a couple of paragraphs to the README describing the real life scenarios and people including their goals and how it is intended to be used.
* The README should include information about overall application components, process, server infrastructure, and dependencies that people will need to understand to understand the application.
* The README should describe how to run the tests.
* The README should describe which systems and browsers are supported.
* The README should describe how a developer can get the application up and running.
* Prefer adding documentation to the `README` and `docs/` over the wiki. If documentation exists elsewhere, link to it from the README.

# SQL

## General

* Write SQL keywords in upper case.
* Write table names, column names, and aliases in lower case.
* Put primary keywords for the main query at the beginning of a new line.
  * Example:

  ```sql
  SELECT ...
  FROM ...
  WHERE ...
  ORDER BY ...
  ```
* When using heredoc for SQL strings, use `<<-SQL` as the opening tag.
  This allows for SQL syntax highlighting in certain text editors.
* For performance reasons, prefer Common Table Expressions over subqueries when available.
* Avoid making materialized views that depend upon other materialized views.

## SELECT

* Put the first selected column on the same line as `SELECT`. Put each additional
  selected column name on its own line, indented by two spaces.
  * Example: 

  ```sql
  SELECT users.first_name,
    users.last_name,
    posts.title,
    posts.body
  FROM ...
  ```
* Qualify column names with their table name if the query involves more than one table.
* Alias column names at will.


## FROM

* In general, avoid aliasing tables; use the full table name instead.
* **Do** alias tables when your query refers to the same table more than once in
  different contexts. In this case, choose aliases that explain how the table is
  used differently in each context.
  * Example:

  ```sql
  SELECT supervisors.first_name AS "supervisor_first_name",
    supervisors.last_name AS "supervisor_last_name",
    employees.first_name AS "employee_first_name",
    employees.last name AS "employee_last_name"
  FROM people AS "employees"
    JOIN people AS "supervisors"
      ON employees.supervisor_id = supervisors.id
  ```

### JOIN

* Start `JOIN` clauses on the line after the `FROM` clause, indented by two spaces.
* Start `ON` clauses on the line after its `JOIN` clause, indented by two spaces
  more than the `JOIN` line.
* Start `AND` or `OR` clauses on the line after the `ON` clause, indented by
  two spaces more than the `ON` line.

  ```sql
  SELECT ...
  FROM assays
    JOIN preps
      ON assays.source_id = preps.id
        AND assays.source_type = 'Prep'
    JOIN cultures ...
      ON ...
  WHERE ...
  ```

## WHERE

* Start `AND` or `OR` clauses on the line after the `WHERE` clause, indented by
  two spaces more than the `WHERE` line.
* If parentheses are required or clarifying, start a new line after the opening
  paren and indent lines inside the parentheses. Place the closing paren on a new
  line indented as far as the start of the line where the parentheses start:

  ```sql
  SELECT ...
  FROM ...
  WHERE scored_on IS NOT NULL
    OR (
      discarded = TRUE
        AND id < 500
    )
  ORDER BY ...
  ```

## Nested queries

* Give explanatory aliases to nested queries when it is needed or clarifying
* Start a new line after the opening paren and indent lines inside the parentheses.
  Place the closing paren on a new line indented as far as the start of the line
  where the parentheses start, followed by the alias if one is used:

  ```sql
  SELECT ...
  FROM (
    SELECT COUNT(*) AS "num_positions_filled",
      box_id
    FROM stocks
    WHERE disabled_on IS NULL
    GROUP BY box_id
  ) AS "box_counts"

  ```
* Use the same style guidelines as the main query, but indented.
