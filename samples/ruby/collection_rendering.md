```erb
# Bad
<% @post.comments.each do |comment| %>
  <%= render partial: 'comment', locals: { comment: comment } %>
<% end %>

# Good
<%= render partial: 'comment', collection: @post.comments %>
```
