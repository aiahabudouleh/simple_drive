Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users, only: [:index, :show, :new, :create]

  get '/login'     => 'sessions#new'
  post '/login'    => 'sessions#create'
	delete '/logout' => 'sessions#destroy'  
  post '/sign-up'  =>  'users#create'
  root to: 'users#new'

  post 's3_files/upload', to: 's3_files#upload', as: :upload_file
  get 's3_files/download/:filename', to: 's3_files#download', as: :download_file

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
