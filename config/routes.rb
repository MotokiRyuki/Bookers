Rails.application.routes.draw do
  post "/sign_in", to: "sessions#create"
  resource :user, only: [:show]
end
