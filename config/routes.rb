ManybotsInstagram::Engine.routes.draw do
  resources :instagram do
    collection do
      get 'callback'
    end
    member do 
      post 'toggle'
    end
  end
  
  root to: 'instagram#index'
end
