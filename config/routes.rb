Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      namespace :auth do
        resource :sign_in, only: :create
        resource :sign_out, only: :destroy
        resource :sign_up, only: :create
        resources :sign_up, only: [], param: :token do
          resource :callback, only: [ :create, :show ], module: :sign_up
        end
        resource :password_reset, only: [ :create, :update ]
      end
    end
  end
end
