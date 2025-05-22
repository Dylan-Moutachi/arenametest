require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  get "bookings/import"
  namespace :api do
    namespace :v1 do
      resources :bookings, only: :index do
        collection { post :import }
      end
    end
  end
end
