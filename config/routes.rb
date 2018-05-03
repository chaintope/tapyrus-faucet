Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'monacoin/testnet/transactions#index'

  get 'monacoin', to: 'monacoin/transactions#index'

  namespace :monacoin do
    resources :transactions, only: [:index, :create]

    namespace :testnet do
      resources :transactions, only: [:index, :create]
    end
  end
end
