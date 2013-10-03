# Table of Contents
* [Back To Developing Rails applications](../)
  * [Migrations] (#migrations)
  * [Seeds] (#seeds)

## Migrations

* **Do Not** use `rake db:migrate` to build the database schema for a new application.
  Migrations are intended to be run from a certain point in time for existing production
  systems and are not intended to always work. Use `rake db:schema:load` and `rake db:seed`
  to build the database schema, this is faster and will not cause unintended errors.
* Keep the `schema.rb` (or `structure.sql`) under version control.
* Use `rake db:test:prepare` to update the schema of the test database.
* Enforce default values and not null constraints in the migrations themselves instead of in
  the application layer.
* When writing constructive migrations (adding tables or columns), use
  the new Rails 3.1+ way of doing the migrations - use the `change`
  method instead of `up` and `down` methods.
* Older migrations should be periodically archived in `db/migrate/archived_migrations`

## Seeds

* Avoid developing against production data dumps.
* Create and update seeds as you develop.
* Seeds should mirror the current state of the app and provide enough
  data to access and test all features of the application.
* Basic data needed for all environments, including production, should be in the
  `db/seed.rb` file.
* Other seeds should be kept in the `db/seeds` directory.
* Rake tasks should be created in the db:seed namespace for development data.

### Seed Maintainance Strategies

* Use your Factory Girl factories to seed development data. They are likely to be 
  updated as your objects change.
* Run the seeds in your test suite, or on CI (based on time) and fail the build
  they break.
* Create a generator that creates a seed file when you create a new model.  Opt
  out of creating seeds, instead of opting in.
* Teardown and rebuid your databse regularly.
