Rails.application.routes.draw do
  resources :calls

  resources :subscribers

  resources :user_files
end
