Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  
  resources :stores do
    resources :products, only: [:index]
    #get "/orders/new" => "stores#new_order"
  end
  
  get 'welcome/index'
  get "listing" => "products#listing"
  get "me" => "registrations#me"
  get "user_listing" => "registrations#user_listing", as: :user_listing
  get 'orders/new', to: 'orders#new', as: 'new_order'

  
  post "new" => "registrations#create", as: :create_registration
  post "sign_in" => "registrations#sign_in"
  
  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  resources :registrations, only: [:index] do
    member do
      patch :change_role
    end
  end

  resources :stores do
    member do
      patch :disable_user
    end
  end

  resource :cart, only: [:show] do
    post 'add_item/:product_id', to: 'carts#add_item', as: 'add_item'
    delete 'remove_item/:cart_item_id', to: 'carts#remove_item', as: 'remove_item'
  end

  resources :orders, only: [:create, :index, :show]
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Defines the root path route ("/")
  root to: "welcome#index"
end
