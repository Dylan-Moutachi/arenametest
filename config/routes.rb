Rails.application.routes.draw do
  get "bookings/import"
  namespace :api do
    namespace :v1 do
      resources :bookings do
        collection { post :import }
      end
    end
  end
end
