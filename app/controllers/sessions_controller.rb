# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
    # Be sure to include AuthenticationSystem in Application Controller instead
    #include AuthenticatedSystem

    skip_filter :login_required, :only => [:new,:create]
    skip_filter :agreed, :only => [:destroy,:new,:create] # new and create only needed since user may be logged in with other account that is not agreed yet 



    def new
    end

    def create
        self.current_user = User.authenticate(params[:login], params[:password])
        if logged_in?
            if params[:remember_me] == "1"
                current_user.remember_me unless current_user.remember_token?
                cookies[:auth_token] = { :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
            end
            #redirect_to show_user_path

            if session[:last_action]
                redirect_to session[:last_action]
            else
                redirect_to show_user_path
                #redirect_to :controller => 'account', :action => 'index'
            end



            flash[:notice] = "Logged in successfully"
        else


            if params[:login]

                @u = User.find_by_login(params[:login])
                if(@u!=nil and @u.activated_at == nil)
                    flash[:notice] = "You must activate your account before logging in. Click 'Forgot password' to receive a new activation email"
                else
                    flash[:notice] = "Incorrect username or password"
                end
            end
            render :action => 'new'
        end


    end

    def destroy
        self.current_user.forget_me if logged_in?
        cookies.delete :auth_token
        reset_session
        flash[:notice] = "You have been logged out."
        render :action=>'bye'
    end

    def bye

    end
end
