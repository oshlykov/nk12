Nkapp::Application.routes.draw do
  get "sessions/new"

  #resources :comments
  
#  scope '(:elections)', :elections => /1|2/ do
  
  resources :users, :password_resets

  resources :folders do
    resources :pictures, :only => [:create]
    post :release, :on => :member
  end

  resources :elections do
    get 'region_list', :on => :member
  end

  resources :commissions, :path => '/uik' do
    resources :protocols do
      resources :votings
      resources :pictures, :only => [:create, :destroy]
    end
    get 'add_watcher', :on => :member
    get 'del_watcher', :on => :collection
    get 'get_csv/:cik' => "commissions#get_csv", :on => :member, :as => "get_csv"
    get 'get_full_karik_2011', :on => :collection
    get 'get_full_karik_2012', :on => :collection
    get 'get_candidates_karik_2011', :on => :collection
    get 'get_candidates_karik_2012', :on => :collection
  end

  #get "protocols/cheking", :controller => 'protocols', :action => 'cheking'
  resources :protocols do
    collection do
      get 'checking'
      post 'unfold/:folder_id', :action => :unfold
    end
    member do
      post 'check'
      delete 'trash'
    end
    resources :votings
  end

  resources :pictures, :only => [:index, :create, :destroy] do
    get 'rotate/:direction' => "pictures#rotate", :as => 'rotate', :direction => /(cw|ccw)/
  end
  #get "verify/index"

  match 'uik_by/:id' => 'home#uik_by'
  match 'uik_by' => 'home#uik_by'
  #   match 'products/:id' => 'catalog#view'

  root :to => "home#index"

#-  devise_for :users
  resources :sessions
  #get "login" => "sessions#new", :as => "login"
  #resources :users, :only => :show
  #resources :home
  #resources :verify

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

  match '/exchange' => "exchange#index"
  namespace :exchange do
    get 'export_prepare'
    get 'export'
  end

end
