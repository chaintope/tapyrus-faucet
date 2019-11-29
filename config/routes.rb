Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'tapyrus/transactions#index'

  namespace :tapyrus do
    resources :transactions, only: [:index, :create]
  end
end
