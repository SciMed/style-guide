```rb
# frozen_string_literal: true

class AddAuthorColumnToUsers < ActiveRecord::Migration
  class User < ApplicationRecord
  end
  class Article < ApplicationRecord
    belongs_to :user
  end

  def up
    add_column :users, :author, :boolean, default: false
    
    ActiveRecord::Base.connection.schema_cache.clear!
    User.reset_column_information
    
    Article.includes(:user).find_each do |article|
      article.user.update!(author: true)
    end
  end
  
  def down
    remove_column :users, :author
  end
```
