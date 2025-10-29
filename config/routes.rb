Rails.application.routes.draw do
  post "new_intake/create"
  get "dashboard/index"
  root "dashboard#index"
end
