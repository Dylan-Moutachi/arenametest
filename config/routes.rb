require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :bookings, only: :index do
        post :import, on: :collection
      end

      resources :bookings_imports, only: :show
    end
  end
end
