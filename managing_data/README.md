## Migrations

* **Do Not** use `rake db:migrate` to build the database schema for a new application.
  Migrations are intended to be run from a certain point in time for existing production
  systems and are not intended to always work. Use `rake db:schema:load` and `rake db:seed`
  to build the database schema, this is faster and will not cause unintended errors.
* Keep the `schema.rb` (or `structure.sql`) under version control.
* Use `rake db:test:prepare` to update the schema of the test database.
* Enforce default values in the migrations themselves instead of in
  the application layer.
* When writing constructive migrations (adding tables or columns), use
  the new Rails 3.1+ way of doing the migrations - use the `change`
  method instead of `up` and `down` methods.
* Older migrations should be periodically archived in `db/migrate/archived_migrations`
