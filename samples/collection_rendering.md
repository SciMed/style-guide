```erb
# bad
<% @post.comments.each do |comment| %>
  <%= render partial: 'comment', locals: { comment: comment } %>
<% end %>

# good
<%= render partial: 'comment', collection: @post.comments %>
```
