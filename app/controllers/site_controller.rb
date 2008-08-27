class SiteController < ApplicationController

    skip_filter :login_required, :only => [:index,:list_emails,:show_email  ]
    
    def index
        if logged_in?
            @user = current_user
            redirect_to(@user)
        end
    end



    def list_emails   
        logger.info("in list_emails")

        if TESTSERVER==false
            redirect_to "/" unless TESTSERVER==true
            return
        end


    end

     def show_email
         if TESTSERVER==false
             redirect_to "/" unless TESTSERVER==true
             return
         end
         
         @delivery = ActionMailer::Base.deliveries.last
         render :action => "show_email", :layout => false
    end


    def feedback
        logger.info("in feedback")

        if request.post?
            logger.info("message is "+params[:message])

            UserMailer.deliver_feedback_notification(self.current_user,params[:message])
            flash[:notice] = 'Feedback successfully sendt.'
            
        end

    end

end
