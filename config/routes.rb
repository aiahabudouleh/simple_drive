Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users, only: [:index, :show, :new, :create]

  get '/login'     => 'sessions#new'
  post '/login'    => 'sessions#create'
	delete '/logout' => 'sessions#destroy'  

  root to: 'users#new'

  namespace :api do
    namespace :v1 do
      resources :blobs do
        member do
          resources :blobs, only: [:create]
        end
      end
    end
  end

end
