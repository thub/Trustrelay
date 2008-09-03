# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

    before_filter :login_required
    before_filter :agreed



    #hkjahsd

    helper :all # include all helpers, all the time

    include AuthenticatedSystem
    include SimpleCaptcha::ControllerHelpers  


     def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to new_session_path
        end
#        format.any do
#          request_http_basic_authentication 'Web Password'
#        end
      end
    end

    # if user has logged in then user has to have accepted the eula to proceed
    def agreed
        session[:last_action] = request.env['REQUEST_URI'] #unless logged_in? && authorized?
        if self.current_user!=nil and !self.current_user.accepted?
            redirect_to accept_agreement_path
        end
    end


    def login_required
        session[:last_action] = request.env['REQUEST_URI'] unless logged_in? && authorized?
      authorized? || access_denied
    end

    def flash_redirect(msg, *params)
        flash[:notice] = msg
        redirect_to(*params)
    end

    # redirect somewhere that will eventually return back to here
    def redirect_away(*params)
        session[:original_uri] = request.request_uri
        redirect_to(*params)
    end

    # returns the person to either the original url from a redirect_away or to a default url
    def redirect_back(*params)
        uri = session[:original_uri]
        session[:original_uri] = nil
        if uri
            redirect_to uri
        else
            redirect_to(*params)
        end
    end

    protected
# Protect controllers with code like:
    #   before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
    def admin_required
        current_user.respond_to?('is_admin') && current_user.send('is_admin')
    end

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery  :secret => '0785726ea34a942c03cee8c31f08326a'



end
