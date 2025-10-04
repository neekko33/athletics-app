Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  root "competitions#index"
  resources :competitions do
    resources :athletes, only: [ :index, :new, :create ]
  end
  resources :events
end
