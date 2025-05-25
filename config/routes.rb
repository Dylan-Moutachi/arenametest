require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :bookings, only: :index do
        post :import, on: :collection
      end

      resources :bookings_imports, only: [] do
        get :status, on: :member
      end
    end
  end
end
