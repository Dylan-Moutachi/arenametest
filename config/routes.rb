Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :bookings do
        collection { post :import }
      end
    end
  end
end
