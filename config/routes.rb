Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'koto', to: 'koto/transactions#index'

  namespace :koto do
    resources :transactions, only: [:index, :create]
  end
end
