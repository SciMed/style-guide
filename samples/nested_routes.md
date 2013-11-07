```Ruby
# bad
resources :users do
  resources :posts do
    resources :comments
  end
end

# good
resources :users do
  resources :posts
end

resources :posts  do
  resources :comments
end
```
