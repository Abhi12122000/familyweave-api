Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: 'api/v1/users/sessions',
        registrations: 'api/v1/users/registrations'
      }

      resources :family_trees, only: [:create] do
        collection do
          get :mine # For GET /api/v1/family_trees/mine
        end
        resources :family_tree_nodes, only: [:create], controller: 'family_tree_nodes' # For POST /api/v1/family_trees/:family_tree_id/nodes
      end
      # We might add more routes for nodes later, e.g., direct access or updates
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
