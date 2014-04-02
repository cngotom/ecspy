Ecspy::Application.routes.draw do
  



  get "ztc/check",:as => :ztc_check
  get "ztc/status",:as => :ztc_status
  get "ztc/proxy",:as => :ztc_proxy
  post 'ztc/clear',:as => :ztc_clear
  post "ztc/save",:as => :ztc_save


  get "file_upload/index"

  post "file_upload/upload"

  match "user_center/index" => 'user_center#index' ,:as => :user_root

  root to: 'user_center#index'

  devise_for :users,:controllers => { :registrations => "registrations" }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)



  match 'shop_items/:id/content/:fversion/:sversion' => 'shop_items#content_compare', :as => :content_compare



  resources :shop_items do
    member do
      #get  'content/:fversion/:sversion' => 'shop_items#content_compare', :as => :content_compare
    end
  end


  namespace :user_center do 
    resources :shops do

      collection do

        post 'subscribe'

        post 'unsubscribe'

        get 'compare'
      end

    end


    resources :items


    resources :sales


    resources :keywords

    resources :keyword_records do
      member do 
        get 'trend'
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
