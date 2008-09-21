ActionController::Routing::Routes.draw do |map|
    map.resources :replies

    map.resources :apps

    map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'

    map.resources :items
    map.resources :relationships
    map.home '/', :controller => "site", :action => 'index'
    map.feedback '/feedback', :controller => "site", :action => 'feedback'
    map.list_emails '/emails', :controller => 'site', :action => 'list_emails'
    map.show_email '/email', :controller => 'site', :action => 'show_email'

    map.resource :session


    map.resources :users, :member => {
            :suspend => :put,
            :unsuspend => :put,
            :purge => :delete
    }
    map.resource :session
    map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'

    map.activate_merge '/activate_merge/:activation_code', :controller => 'users', :action => 'activate_merge'
    map.signup_relationship '/signup_relationship', :controller => 'users', :action => 'new'
    map.signup '/signup', :controller => 'users', :action => 'new_signup'
    map.login '/login', :controller => 'sessions', :action => 'new'
    map.logout '/logout', :controller => 'sessions', :action => 'destroy'
    map.chance_password '/user/change_password', :controller => 'users', :action => 'change_password'
    map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
    map.forgot_password_result '/forgot_password_result', :controller => 'users', :action => 'forgot_password_result'
    map.reset_password '/reset_password/:code', :controller => 'users', :action => 'reset_password'
    map.account '/account', :controller => 'users', :action => 'account'


    map.add_application '/add_application', :controller => 'jumps', :action => 'add_application'

    map.unlink_user '/unlink/:id', :controller => 'users', :action => 'unlink', :method => "post"
    map.merge_user '/merge', :controller => 'users', :action => 'merge'
    map.welcome_user '/welcome', :controller => 'users', :action => 'welcome'
    map.add_user '/user/add', :controller => 'users', :action => 'add'
    map.edit_user '/user/edit', :controller => 'users', :action => 'edit'
    map.update_user '/user/update', :controller => 'users', :action => 'update'
    map.destroy1_user '/user/destroy1', :controller=>'users', :action => 'destroy1'

    map.toggle_show_help'/users/:id/toggle', :controller=>'users', :action => 'toggle_show_help'
    map.show_user '/user', :controller => 'users', :action => 'show'
    map.accept_agreement '/user/accept', :controller => 'users', :action => 'accept_agreement'
    map.decline_agreement '/user/decline', :controller => 'users', :action => 'decline_agreement'


    map.new_app '/jumps/:jump_id/applications/new', :controller => 'apps', :action => 'new'

    map.new_reply '/item/:item_id/to/:to_id/replies/new', :controller => 'replies', :action => 'new'
#    map.new_reply_owner '/item/:item_id/user/:user_id/new', :controller => 'replies', :action => 'new'
#    map.new_reply_to '/item/:item_id/to/:to_id/new', :controller => 'replies', :action => 'new'
    map.activate_relationship '/activate_relationship/:activation_code', :controller => 'relationships', :action => 'activate'

    map.new_item '/item/new', :controller=>'items', :action => 'new'
    map.create_item '/item/create', :controller=>'items', :action => 'create'
    map.list_items '/items', :controller=>'items', :action => 'index'
    map.show_item '/items/:id', :controller=>'items', :action => 'show'

    map.edit_item '/items/:id/edit', :controller=>'items', :action => 'edit'
    map.update_item '/items/:id/update', :controller=>'items', :action => 'update'
    map.destroy_item '/items/:id/destroy', :controller=>'items', :action => 'destroy'
    map.forward_item '/items/:id/forward', :controller=>'items', :action => 'forward'
    map.toggle_interest '/items/:id/toggle', :controller=>'items', :action => 'toggle'
    map.close_item '/items/:id/close', :controller=>'items', :action => 'close'
    map.open_item '/items/:id/open', :controller=>'items', :action => 'open'

    # The priority is based upon order of creation: first created -> highest priority.

    # Sample of regular route:
    #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   map.resources :products

    # Sample resource route with options:
    #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

    # Sample resource route with sub-resources:
    #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

    # Sample resource route within a namespace:
    #   map.namespace :admin do |admin|
    #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
    #     admin.resources :products
    #   end

    # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
    # map.root :controller => "welcome"

    # See how all your routes lay out with "rake routes"

    # Install the default routes as the lowest priority.
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
end
