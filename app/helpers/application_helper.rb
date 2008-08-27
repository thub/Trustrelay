# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def user_logged_in?
        session[:user_id]
    end


    def user_is_admin?
        session[:user_id] && (user = User.find(session[:user_id])) && user.is_admin
    end


end
