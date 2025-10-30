Rails.application.routes.draw do
  post "new_intake/create"
  get "dashboard/index"
  put "audit/update", to: "audit#update"
  root "dashboard#index"
end
