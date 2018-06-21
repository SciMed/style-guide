```Ruby
# Bad
resources :users do
  resources :posts do
    resources :comments
  end
end

# Good
resources :users do
  resources :posts
end

resources :posts  do
  resources :comments
end
```
