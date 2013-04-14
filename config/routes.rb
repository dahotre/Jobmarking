Jobmarking::Application.routes.draw do
  resources :lookups


  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end