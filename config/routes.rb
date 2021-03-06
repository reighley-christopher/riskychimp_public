Riskybiz::Application.routes.draw do

  resources :app_settings, :only => [:edit, :update]


  # This line mounts Refinery's routes at the root of your application.
  # This means, any requests to the root URL of your application will go to Refinery::PagesController#home.
  # If you would like to change where this extension is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Refinery relies on it being the default of "refinery"
  devise_for :users, :controllers => { :confirmations => 'users/confirmations', :passwords => 'users/passwords' }
  resources :users, :only => [:show, :edit, :update] do
    member do
      match :change_password
      get :setting
      put :update_setting
    end

    collection do
      get :report_error
    end

    resources :reviewers, :controller => "users/reviewers"
  end
  resources :transactions do
    member do
      put :change_status
      get :email_detail
    end
    collection do
      put :update_amount_threshold
    end
    resources :notes
  end
  resources :api, :only => [] do
    collection do
      post :transactions
    end
  end
  resources :articles do
    collection do
      get :feed
    end
  end
  namespace :admin do
    resources :users do
      member do
        get :invite
        post :login
      end
    end
  end
  match 'fingerprint/fingerprint.swf' => 'fingerprint#download', defaults: { format: 'swf' }
  match 'fingerprint/fingerprint.js' => 'fingerprint#download', defaults: { format: 'js' }
  match 'fingerprint/phonehome' => 'fingerprint#phonehome'
  mount Refinery::Core::Engine, :at => '/'

  Refinery::Core::Engine.routes.draw do
  resources :articles

    devise_for :users, :controller => { :confirmations => 'users/confirmations', :passwords => 'users/passwords' }
    resources :users, :only => [:show, :edit, :update] do
      member do
        match :change_password
        get :setting
        put :update_setting
      end
    end
    resources :transactions do
      member do
        put :change_status
      end
      collection do
        put :update_amount_threshold
      end
      resources :notes
    end
    resources :api, :only => [] do
      collection do
        post :transactions
      end
    end
    namespace :admin do
      resources :users do
        member do
          get :invite
          post :login
        end
      end
    end
  end


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
  # match ':controller(/:action(/:id))(.:format)'
end
