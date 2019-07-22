# :high_heel: A Highly Fashionable Style Guide

This guide provides a set of best practices and style prescriptions
for application development based on SciMed Solutions' years
of development experience.

**Read this before making any changes to the style guide**

If you make any changes to the style guide, please clearly describe the logic that led to the decision in your commit message. Developers who are not privy to the initial discussion will need to understand why the decision was made in order to evaluate whether the decision is still relevant and whether it is pertinent to their current situation.

#### The Runway

* [Ruby](#ruby)
* [Rails](#rails)
* [JavaScript](#javascript)
* [JSON](#json)
* [SCSS](#scss)
* [HTML](#html)
* [RSpec](#rspec)
* [SQL](#sql)
* [Performance](#performance)

# Ruby
* Adhere to Rubocop when possible.
  * See our default [`.rubocop.yml`](./.rubocop.yml).
* Mark instance methods as private by calling `private def foo` when using recent Ruby versions (> 2.1.0). For earlier versions, mark methods as private by calling `private :my_method` directly after the end of the method.
* Mark class methods as private by calling `private_class_method def self.foo` when using recent Ruby versions (> 2.1.0). For earlier versions, mark methods as private by calling `private_class_method :my_method` directly after the end of the method.
* Keep private instance methods clustered together at the end of the file.
* Keep private class methods clustered together after public class methods but before public instance methods.
* Write arrays on a single line when they are fewer than 80 characters long. Otherwise, write them as one line per item.
  * [Example](samples/ruby/arrays.md)
* Avoid meta-programming classes for reasons of readability.

#### Documentation
* When documenting methods use [Yard](http://yardoc.org/) style documentation. This is especially important when purpose, parameters, or return values are ambiguous.
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

#### General
* Pretty much all of the application's code should stay out of `lib/`. Think of `lib/` as a place to put components that are generalized enough that they could be used in other applications (but then why not make those things into gems?).
* Organize objects into `app/`: `presenters/`, `services/`, `serializers/`, `validators/`. If you have another collection of objects that are general enough to warrant their own folder, feel free to do so (e.g. `app/forms`).
* Organize classes into namespaces when appropriate.
* Treat acronyms as words in class names.
  * [Example](samples/ruby/camelcasing.md)
* Consider using methods instead of constants. Methods are easier to stub, test, and mark private.

#### Routing

* Avoid more than 1 level of resource nesting.
  * [Example](samples/ruby/nested_routes.md)
* Do not use the `match` wildcard route matcher.

#### Controllers

* Structure Controller content **[in this order](samples/ruby/controller.md)**.
* Try to avoid adding non RESTful actions to a resource. Consider if a non RESTful action for one controller could be a RESTful action for a new controller (that does not necessarily map to a model).
* Storing anything other than the session id in session is discouraged.
  * This can be a security risk unless done carefully. This also makes the browser part of the current state of the application, allowing things to get out of whack. For example keeping the current working record in the session causes problems if users try to use the application with more than one tab or window.
* Keep controllers skeletal—they shouldn't contain business logic.
* Controllers should ideally only have the following responsibilities:
  * Looking up objects
  * Redirecting
  * View rendering
  * Set flash
  * Assigning raw params to objects
    * Converting params into the form they will take in the database should be done via service objects
  * Wrapping objects in presenters
  * Authentication/authorization
  * Instantiating/calling service objects
* If you find yourself needing more than two instance variables consider using a Presenter object, which could be more easily unit tested.
* If you use code generation tools (e.g. scaffold) remove any unused code like `respond_to` blocks.
* Ensure there is a method in the controller for every route that is rendered even if the method is empty.

#### Models

* Structure model content **[in this order](samples/ruby/model.md)**.
* Using non-ActiveRecord models is encouraged.
* Avoid adding `default_scope`.
* Avoid adding callbacks in favor of [an object decorator](samples/ruby/callback.md).
* Avoid adding callbacks that modify other models.
* Use of `class << self` is discouraged in ActiveRecord models.
* Use of `has_and_belongs_to_many` is *strongly* discouraged.  Use `has_many :through` instead.
* Use a Validator object for custom validations.
  * [Example](samples/ruby/validator.md)
* Use of `update_attribute`, `update_column`, `update_columns`, and `update_all` skip validations. Rubocop should help you with this. `update_attribute` will also persist changes to any other dirty attributes on your model as well, not just the attribute that you are trying to update. However, if you do not need validations or callbacks, `update_column` is preferred over update_attribute because it is easier to remember that it does not run validations.
* When accessing associations through other associations, use `has_many` or `has_one` `through` rather than a delegation or a custom method **when all target objects in the associations are persisted**. Use delegations or custom methods **when there is useful data that is not yet persisted**. Keeping the data in associations allows preloading to prevent n+1 queries and ensures that more processing is done via SQL than Ruby, which is more performant. Unfortunately, associations `through` other associations will not see non-persisted objects.

#### Views

* Accessing database models or the database from the view breaks the separation that is the goal of MVC. It would be best to build presenter objects which store the data needed for the view.
* Never make complex formatting in the views, moving the formatting to
  a presenter object.
  * For example, if you are displaying a schedule, do not put the logic for grouping events into days in the view.
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
* Ensure that label tags connect with the correct form input.
  * Note that `form_with` does not do this automatically.
* Don't make partials for the fun of it. It is discouraged to have partials more than 2 levels deep.
  * This is both for ease of maintainability and performance.
* Partials should rely on local variables rather than instance variables.
* Utilize collection rendering rather than rendering a partial for each element
  in a collection for purposes of performance.
  * [Example](./samples/ruby/collection_rendering.md)
* For new projects, use ERB as the templating engine. For old projects, use whatever is already in place.
* Try to avoid multiline embedded Ruby—it's likely indicative of logic that should be extracted to a presenter, service object, or helper. When necessary, use the following format:
```
<%
  some_long_ruby
  some_more_long_ruby
%>
```

#### Migrations

* Both `schema.rb`/`structure.sql` and migration files should be maintained so that developers can migrate from scratch or load the schema.
* Migrations should define any classes that they use (if the class is deleted in the future, the migrations should still be able to run).
* Use those database features! Enforce default values, null constraints, uniqueness, etc. in the database (via migrations) in addition to the application layer, as the database can avoid race conditions and is faster and more reliable.
* If you have `NOT NULL` constraints, be sure to add a `dependent` option on the association. Otherwise, you will get invalid query exceptions when things are deleted. Also, consider a foreign key with the `CASCADE` option.
* When you create a new migration, run it both `up` ***and*** `down` before committing the change (`rake db:migrate:redo` will run the very last migration down and then up again).
* Prefer using `change` in migrations to writing individual `up` and `down` methods when possible.
* Make sure to update seeds/factories when adding columns (particularly those with validations) or tables.
* If you are doing something that cannot be reversed (such as removing data or deleting a column), raise `ActiveRecord::IrreversibleMigration` in your `down` method. Please leave a comment about why the migration is irreversible.
* If you are modifying data in a migration be sure to call two methods at the beginning of the migration. If you don't reset the column information then some data could be silently lost instead of saved. Also, Rails will only reset column information once even if you call it multiple times, which is why the `schema_cache` needs to be cleared first.

```ruby
Model.connection.schema_cache.clear!
Model.reset_column_information
```

#### Seeds

* Avoid relying on production database dumps for development. Make sure there are reliable seeds so that future developers can get up and running and access all features quickly.
* Create and update seeds as you develop.
* Seeds should be capable of running multiple times without producing errors or bad duplicates.
* Seeds should mirror the current state of the app and provide enough data to access and test all features of the application.
* Data needed for all environments, including production, should be in seeds.
* Other seeds should be kept in the `db/seeds` directory.
* Structure the seeds as follows:
```
db/
  seeds/
    development/
      model_1.rb
    production/
      model_1.rb
    staging/
      model_1.rb
    development.rb
    production.rb
    staging.rb
  seeds.rb
```
* Consider using [Seed Bank](https://github.com/james2m/seedbank) to help with your seeds.
* Consider using FactoryGirl/Bot factories to seed development data.
* Tear down and rebuild your database regularly.

#### Mailers

* Provide both HTML and plain-text view templates.
* If you need to use a link in an email, always use the `_url`, not `_path` methods, to ensure the absolute path is correct.
* Format the from and to addresses as `Your Name <info@your_site.com>`.
* Consider sending emails in a background process to prevent page load delays.
* When sending email to multiple users, send an individual email to each person rather than having multiple recipients in one email.
  * This increases security because users can't see each other's addresses and makes it easier to handle errors with invalid email addresses.
* Log when emails are sent and when they fail to send.

#### Bundler
* Structure Gemfile content in alphabetical order with groups at the bottom in the following order:
  * `:development`
  * `:test`
  * `:staging`
  * `:production`
* **Do not** run `bundle update` unless for a specific gem. Updating all of the gems without paying attention could unintentionally break things.
* Remove default comments.
* Versioning is discouraged unless a specific version of the gem is required (but keep an eye out for breaking things when gem versions update!). If you do need to version, add a comment.
* Run `bundle audit` before pushing.
* Prefer using `update --source` or `update --conservative` when you want to update a specific gem without updating its dependencies.

#### Localization/Internationalization (i18n) configuration

* Add a default date and datetime format to your `en.yml`.
* Consider using localization/internationalization config files to encapsulate customer-facing strings such as error messages when:
  * the text is likely to change frequently OR
  * the text is a template that is used in multiple places (i.e. to keep the code DRY). Note that i18n supports [variable interpolation](http://guides.rubyonrails.org/i18n.html#passing-variables-to-translations).
  
#### Logging
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

* Consider logging error messages displayed to users as well.
* When avoiding this logging (due to performance, for example), add a comment to
  the `rescue` block that informs future developers why logging is not
  occurring.

# JavaScript

## General conventions
* Query DOM elements using `data-` attributes instead of CSS classes. CSS classes should be used exclusively for styling, whereas `data-` attributes should be used exclusively for JavaScript querying.
* Any JS involving the DOM should be deferred until the DOM is ready.
* Be careful when including data in the DOM.
  * This is particularly true from a security stand point. Do not put secure or sensitive information in the DOM. For example, do not have a hidden field with a SSN or that determines whether someone is an admin.
  * Just because a user can't see data on the page by default doesn't mean that they can't access it.
* Always prefix jQuery variables with `$`.
  * Example: `$finder = $('.finder')`
* Always prefix Immutable.js variables with `$$`.
  * Example: `$$state`
* When short-circuiting an event listener, explicitly call `event.stopPropagation` and/or `event.preventDefault` as appropriate rather than relying on `return false`.
  * This is because `return false` has different effects in different contexts (see the discussion [here](https://stackoverflow.com/a/4379435)).
* Use an Initializer class to set up application-wide JavaScript functionality such as date pickers, tooltips, dropdowns, and the like.  It should be run with the whole HTML body upon page load and can be re-run with portions of the DOM that are inserted/updated via AJAX.
  * [Example](samples/js/initializers.md)
* Use `getUTCDay()` over `getDay()` to prevent surprises due to time zones.

## Modern JavaScript
All new apps should:

* Aim to support at least ES6/ES2015.
* Use Babel to transpile to ES5+ if called for by browser support requirements.
* Use webpack for bundling and module resolution.
* Use `yarn` for npm package management.

The most straightforward way to meet these requirement is by installing and configuring the `webpacker` gem.

* Prefer the ES6 `import` syntax when possible, but you can use `require` for npm packages where needed.

### eslint

Each project supporting modern JavaScript should use eslint, using a `.eslintrc` file, as in [this example](./.eslintrc) (note that the `env` and `globals` values may vary by project).

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
Only use CoffeeScript on applications that already use it; consider writing new features on those projects in modern JS. You may find the following tool useful for converting JS to CoffeeScript: http://js2.coffee/

When using CoffeeScript:

* Namespace JavaScript objects for related chunks of functionality (Components, Engines, etc...).
  * [Example](samples/js/namespace.md)
* Use JS classes and encapsulation (e.g., IIFE or Object Literal notation) wherever possible.
  * [Class example](samples/js/class.md)
  * [Encapsulation example](samples/js/encapsulation.md)
* Separate responsibilities of vanilla JavaScript into separate entities.
* CoffeeScript file extensions should not include `.js` where possible. Prefer `foo.coffee` to `foo.js.coffee.`
* For ternary operations in CoffeeScript, prefer `if foo then bar else baz`.
* Camelcase variable and function names.

## React
Use React when building complex, stateful UIs.

### Technology Stack
* In addition to the above suggestions:
  * Use Redux.
  * Use [jest](https://github.com/facebook/jest) for testing.

### Redux
* Use selectors to read the state tree.
  * [Example](samples/js/redux_selectors.md)
* Always test your selectors.
* Put selectors in the same file as the reducers for the same part of the state tree.
* Do not mutate the state tree.

# JSON
* If you are designing a JSON API, consider conforming to the [JSON API specification](http://jsonapi.org/format/).
* It is generally considered good practice to keep your JSON structure as shallow as possible.
* Test the schema of JSON generated by your app.
  * Create a JSON schema according to the documentation provided [here](http://json-schema.org/).
  * Check your schema's validity using tools [like this one](http://www.jsonschemavalidator.net/).
  * Add examples to your specs to check JSON generated by your app against the appropriate schema.  The approach [described by Thoughtbot](https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher) using [the json-schema gem](https://github.com/ruby-json-schema/json-schema) has proven successful.

# SCSS
* See [this example](samples/scss/whitespace.md) for whitespace usage.
* Use agreed-upon CSS framework (e.g. [fomantic-ui](https://github.com/fomantic/Fomantic-UI)) where possible.
* Try to group styles by function; consider alphabetizing when unsure.
* Use the SCSS `@import` declaration to require stylesheets vs `*= require`.
* Use the `asset-url` helper for images and fonts.
  * [Example](samples/scss/asset_url.md)
  * Note that if you use any of the Ruby helpers, the file name requires `.erb` at the end of the file name (e.g. `my_styles.scss.erb`).
* Lowercase and dasherize class names.
* Avoid the `>` direct descendant selector when the descendant is a tag for performance reasons.
  * [Example](samples/scss/descendant.md)
* Use caution when using ID selectors.
* Use SCSS variables (for example, colors are often used in multiple places).
* Generic naming is favored over domain-driven naming (e.g. `.aside` vs `.cytometry`).
* Prefer naming elements by content type over visual traits (e.g. `.aside` vs `.left-side-bar`).
* Use `box-sizing: border-box;`.
  * Whenever browsers support it, this allows you to define the size of actual boxes, rather than the size before padding and borders are added. Generally works for IE8+.
* Write out the full hex code in uppercase.
  * Example: `#AAAAAA` instead of `#aaa`.
* SCSS file extensions should not include `.css` where possible. Prefer `foo.scss` to `foo.css.scss`.
* Prefer `.scss` over `.sass`.
* Follow [SMACSS guidelines](https://smacss.com/book/categorizing) for CSS organization (Base, Layout, Module, State, Theme).
* Always use a CSS reset. If the CSS framework being used does not provide one, consider using [normalize-rails](https://github.com/markmcconachie/normalize-rails).

# HTML
* Do not use `<image>` tags for decorative content.
  * [Example](samples/html/images.md)
* Use of presentational markup is discouraged (`<b>`, `<i>`, etc).
* Use of XHTML markup is discouraged, e.g. `<br />`.
* Use layout tags (e.g. `<section>`, `<header>`, `<footer>`, `<aside>`).
  * Note that you are _not_ bound to have only one `<header>` or one `<footer>` tag on a page, but you can only have one `<main>` tag.
* If in a partial, modal file names should be suffixed with `_modal.html.erb`.
* Double-quote raw HTML attributes.
  * Example: `<div id="foo"></div>`

# RSpec

#### General
* Adhere to Rubocop [(rubocop-rspec)](https://github.com/nevir/rubocop-rspec) when possible.
  * See our default [`.rubocop.yml`](./.rubocop.yml).
* Avoid incidental state when setting up expectations.
  * [Example](samples/specs/incidental_state.md)
* Be careful when using iterators to generate tests; they make debugging more difficult (all of the tests share line numbers and the `it` description block). Or consider printing a custom error message to give more information about which test is failing.
  * It's okay not to be DRY if repetition of code improves readability.
* Use factories rather than fixtures.
* Use linting with FactoryGirl/Bot (`FactoryBot.lint`).
* When testing attributes that are set via FactoryBot/Girl, make sure to set the attribute directly in the test rather than relying on the default Factory value.
  * This ensures that someone reading the test only needs to look at the test file to understand what is being checked.
  * Also makes changing the factory less destructive.
* Avoid redefining parts of the application in tests. For example, don't re-define `Rails.development?`.
* Follow the whitespace guide [here](https://github.com/SciMed/style-guide/blob/master/samples/specs/whitespace.md).
* Prefer `let!` over `let` and `before`.
* Review the [internal best practices guide](https://git.scimedsolutions.com/scimed/Technical-Knowledge-Base/wikis/testing-lessons-learned) on GitLab.

#### What to test
* Prefer checking exception type over checking a specific error message.
* Use shared examples to test common behavior, but avoid including tests that take a long time to execute.
* Use [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) for testing validations, associations, and delegations in models.
* Prefer testing complicated scopes using an integration test that confirms the expected behavior against persisted records.
* Extract complicated scopes into a QueryBuilder object for easier unit-testing.

#### Mocking and stubbing

* Use `let` blocks for assignment instead of `before(:each)` (`let` blocks are lazily evaluated).
* Stub all external connections (HTTP, FTP, etc).
* Prefer writing integration tests over controller tests.

#### Expectation syntax
* Favor new syntax (on new projects, use RSpec 3.0+), e.g. favor `expect` over `should` on RSpec 2.11+.

#### Description blocks

* Always provide a description string to `it` blocks unless the block contains a [Shoulda Matcher](http://matchers.shoulda.io/) expectation.
* Keep the full spec description as grammatically correct as possible.
  * [Example](samples/specs/full_description.md)
* Format `describe` block descriptions for class methods as `'.some_class_method_name'` and for instance methods as `'#some_instance_method_name'`.
* Avoid conditionals in `it` block descriptions. Instead, use `context` blocks to organize different states.
  * [Example](samples/specs/conditional_block_description.md)
* Prefer using only one expectation per `it` block for unit tests.
  * If setup is expensive, it may be reasonable to use multiple expectations in a single `it` block.

#### Capybara
* Prefer using `describe`, `context`, and `it` instead of `feature` and `scenario`.

# Documentation
* Keep the README in the project root directory.
* Use markdown in the `docs/` directory when appropriate.
* When a new medium or large feature gets added, add a paragraph or a couple of paragraphs to the README describing the real life scenarios and people including their goals and how it is intended to be used.
* The README should include information about overall application components, process, server infrastructure, and dependencies that people will need to understand to understand the application.
* The README should describe how to run the tests.
* The README should describe which systems and browsers are supported.
* The README should describe how a developer can get the application up and running.
* The README should describe the deploy process.
* Prefer adding documentation to the `README` and `docs/` over the wiki. If documentation exists elsewhere, link to it from the README.
* If you notice any of the above has become outdated, update the README accordingly.

# SQL

## General

* Write SQL keywords and function calls in upper case.
* Write table names, column names, and aliases in lower case.
* Put primary keywords for the main query at the beginning of a new line.
  * Example:

  ```sql
  SELECT ...
  FROM ...
  WHERE ...
  ORDER BY ...
  ```
* When using heredoc for SQL strings, use `<<~SQL` as the opening tag.
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

# Performance

* Set up [bullet](https://github.com/flyerhzm/bullet) in all development
  environments to detect n+1 queries.
* Consider memory usage and garbage collection. Using too much of a machine's
  memory causes performance issues by itself, but it also leads to more garbage
  collection, which is _very_ slow.
* When appropriate and possible, include filtering/sorting/aggregation logic in
  your SQL queries rather than running a query and operating on the resulting
  relation in Ruby. For example:

  * Use ActiveRecord's `pluck` over Ruby's `map`.
  * Use ActiveRecord's `order` over Ruby's `sort`/`sort_by`.
  * Use ActiveRecord's `maximum` over `map`/`pluck` and Ruby's `max`.
  * Use ActiveRecord's `minimum` over `map`/`pluck` and Ruby's `min`.
  * Use ActiveRecord's `sum` over `map`/`pluck` and Ruby's `sum`.
  * Use ActiveRecord's `average` over a custom `average` or `mean` method.

* Use ActiveRecord's `exists?` over its `any?` for Rails < 5.1.
  [Source](http://www.ombulabs.com/blog/benchmark/performance/rails/present-vs-any-vs-exists.html)
* Use database indexes (including multi-column and partial indexes when
  appropriate).
* Consider using `select` when writing ActiveRecord queries.
  * Not only will the query be faster, Ruby will be able to instantiate fewer
    and lighter-weight objects, thereby leading to less garbage collection.
* Be aware of the following situations where preloading data can lead to
  worsened performance.
  * [Example](./samples/ruby/preloading.md)
* When an association needs to be preloaded, do so at the earliest possible
  opportunity, such as when loading a record with `params[:id]` in the
  controller layer. This will help provide a single source of truth about what
  is loaded into memory. This has several advantages:

  1. Future developers will know whether they need to start or stop preloading
     any associations added or removed in new code.
  1. Future developers will know whether to use Ruby or SQL for data
     filtering (e.g. `where(baz: true)` if the association is not already in
     memory or `select(&:baz?)` when it is already in memory).

* Utilize collection rendering rather than rendering a partial for each element
  in a collection.
  * [Example](./samples/ruby/collection_rendering.md)
* Minimize external resources that need to be fetched upon page load.
  * [Example](./samples/html/google_fonts.md)

* Consider the following performance resources:
  * _Ruby Performance Optimization_ by Alexander Dymo
  * [Rails Guide to Caching](http://guides.rubyonrails.org/caching_with_rails.html)
  * Native extensions such as [fast_blank](https://github.com/SciMed/fast_blank)
  * [Rubocop's performance cops](https://github.com/bbatsov/rubocop/tree/master/lib/rubocop/cop/performance)
  * [Fast Ruby](https://github.com/JuanitoFatas/fast-ruby),
    [fasterer](https://github.com/DamirSvrtan/fasterer) and
    [Erik Michaels-Ober's talk on Writing fast Ruby](https://www.youtube.com/watch?v=fGFM_UrSp70)
    * **NOTE**: the Fast Ruby/fasterer data currently comes only from Ruby 2.2.0
      on OSX; please run the benchmarks in your specific environments to
      validate their suggestions.
  * [ruby-prof](https://github.com/ruby-prof/ruby-prof)
  * [benchmark-ips](https://github.com/evanphx/benchmark-ips)
  * Chrome developer tools' Performance features (including performance audits)

## Tests

* When possible, opt against reading or writing to the database in unit tests.
* Set `config.profile_examples` in your `spec_helper.rb` to see if any tests are
  particularly slow.
* Consider raising the logging level in your `rails_helper.rb` (e.g.
  `Rails.logger.level = 4`).
* When most tables are not populated in a test with Database Cleaner's
  `:truncation` strategy, use `pre_count: true`.
  * [Reference](https://github.com/DatabaseCleaner/database_cleaner#additional-activerecord-options-for-truncation)
* Consider using the `:deletion` strategy with Database Cleaner between specs
  instead of `:truncation` (but always `clean_with :truncation`
  `before(:suite)`).
  * [Reference](https://stackoverflow.com/questions/11419536/postgresql-truncation-speed/11423886#11423886)
* Use FactoryBot >= 4.8 for the config option `FactoryBot.use_parent_strategy` to ensure that associated data is not accidentally created
