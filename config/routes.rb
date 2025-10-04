Rails.application.routes.draw do
  get "grades/index"
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  root "competitions#index"
  resources :competitions do
    resources :grades, except: [ :show ]  # Removed :show action
    resources :athletes do
      collection do
        post :generate_numbers
        post :import
        get :download_template
      end
    end
    resources :heats do
      collection do
        post :generate_all
        post :generate_field_events
      end
    end
    resources :schedules do
      collection do
        post :reorder
      end
    end
  end
  resources :events
end
