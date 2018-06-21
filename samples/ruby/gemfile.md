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