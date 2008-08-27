class UsersController < ApplicationController
    # Be sure to include AuthenticationSystem in Application Controller instead
    # include AuthenticatedSystem

    # Protect these actions behind an admin login
    # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
    before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
    #before_filter :login_required #, :only => [ :index, :show, :edit,:merge ]
    skip_filter :login_required, :only =>
            [:new_test,:new,:create,:activate,:activate_relationship,:forgot_password,:forgot_password_result,:accept_agreement,:decline_agreement,:reset_password]


    #skip_filter :agreed, :only =>
    #[:new_test,:new,:create,:activate,:activate_relationship,:forgot_password,:forgot_password_result,:accept_agreement,:decline_agreement,:reset_password]

    skip_filter :agreed, :only => [:accept_agreement,:decline_agreement]






    # render new.rhtml
    def new
    end

    def new_test
        if TESTSERVER==false and params[:letmein]!="thub"
            flash[:alert] = "Not available in production"
            redirect_to("/")
        end
    end


    # todo. user current user to set relationship

    def create
        cookies.delete :auth_token
        # protects against session fixation attacks, wreaks havoc with
        # request forgery protection.
        # uncomment at your own risk
        #reset_session





        logger.info("before new")
        @user = User.new(params[:user])

        logger.info("after new")
        # setting password here
        @user.password = random_pronouncable_password
        @user.password_confirmation = @user.password



        owner = self.current_user
        #only allowing top level nodes hubertz@online.no or if this is a test server
        if owner==nil
            if @user.login!="hubertz@online.no" and TESTSERVER==false
                flash[:notice] = "You are not allowed to create toplevel node"
                redirect_back_or_default("/")
                return
            end

        end

        logger.info("before register")
        @user.register! if @user.valid?
        logger.info("after register ")
        if @user.errors.empty?
            self.current_user = @user
            #      redirect_back_or_default('/')

            logger.info("activation code is ccc "+@user.activation_code)

            #@activation_url  = "#{SITE}/activate/#{@user.activation_code}"



            if owner then

                @relationship = Relationship.new
                @relationship.owner = owner
                @relationship.target = @user
                @relationship.save();

                @user.initiator = @relationship.owner
                @user.save();

                UserMailer.deliver_signup_notification_relationship(@user)


                flash[:notice] = "Thanks for expanding this network ! Activation code has been sent to "+@user.login
                #flash[:alert] = "http://localhost:3000/activate/"+@user.activation_code
                @user = @relationship.owner # return to correct user



                # need to do this, else newly signed user is logged in
                self.current_user = @user
                redirect_to relationships_path

                #                redirect_to :controller=>"relationships", :action=>"index"
                return
            else
                self.current_user = nil
                UserMailer.deliver_signup_notification(@user)
                flash[:notice] = "Thanks for expanding this network ! Activation code has been sent to "+@user.login
            end

        else
            render :action => 'new'
        end
    end


    def activate
        self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
        if logged_in? && !current_user.active?


            # activate the relationship link that were created when this user was created
            if current_user.initiator==nil
                logger.info("initiator was nil for"+current_user.name)
            else
                relationship = Relationship.find(:first, :conditions=> ['owner_id = ? and target_id = ?', current_user.initiator.id, current_user.id])
                if (relationship==nil)
                    logger.error("Expected relationship when activating user. Found none")
                else
                    relationship.state = 'active'

                    #todo, consider activating target user if taraget user is not active
                end
            end


            current_user.activate!
            relationship.save unless relationship==nil
            flash[:notice] = "Signup complete!"
        end
        redirect_back_or_default('/welcome')
    end

    # todo, is this in use ?
    #    def activate_merge
    #        self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    #        if logged_in? && !current_user.active?
    #            current_user.activate!
    #        end
    #
    #        @user = current_user
    #    end

    def welcome
        @user = current_user
    end


    def show

        if (params[:id])
            @user = User.find(params[:id])

            #todo, check that user is connected to current user
            @limited = true unless @user == self.current_user

            if @user != self.current_user

                #no peeking at users not connected to you
                if !self.current_user.connectedUsers.include?(@user)
                    logger.info("hack attempt") #todo, log IP and block if neccessary

                    reset_session
                    redirect_to "/"
                    return
                end
            end
        else
            @user = current_user
#            if !@user.accepted?
            #                redirect_to accept_agreement_path
            #            end
        end
    end


    def suspend
        @user.suspend!
        redirect_to users_path
    end

    def unsuspend
        @user.unsuspend!
        redirect_to users_path
    end

    def destroy1
        logger.info("in destroy")

        self.current_user.delete!
        reset_session
        redirect_to "/"
    end

    def purge
        @user.destroy
        redirect_to users_path
    end

    def account
        if logged_in?
            @user = current_user
        else
            flash[:alert] = 'You are not logged in - please login first'
            render :controller => 'session', :action => 'new'
        end
    end

    # action to perform when the user wants to change their password
    def change_password
        if request.post?
            logger.info("old password is " +params[:old_password])
            if User.authenticate(current_user.login, params[:old_password])
                current_user.password_confirmation = params[:password_confirmation]
                current_user.password = params[:password]
                if current_user.save
                    flash[:notice] = "Password updated successfully"
                    #redirect_back_or_default('/')
                    redirect_to show_user_path
                    return

                else
                    flash[:alert] = "Password confirmation missmatch"
                    return
                end

            else
                flash[:alert] = "Current password incorrect"
                #redirect_to(self.current_user)
                return

            end
        end
    end



    # action to perform when the users clicks forgot_password
    def forgot_password

        if request.post?
            if @user = User.find_by_login(params[:user][:login])

                if (@user.activated_at==nil and @user.login != 'hubertz@online.no')
                    flash[:alert] = "You must activate your account first.A new activation email has been sendt to you"
                    UserMailer.deliver_signup_notification_relationship(@user)

                    redirect_to '/forgot_password_result'
                    return
                end


                logger.info("in here too")
                @user.forgot_password
                @user.save


                #redirect_back_or_default('/')
                redirect_to '/forgot_password_result'

                flash[:notice] = "A password reset link has been sent to your email address: #{params[:user][:login]}"
                #flash[:alert] = SITE+"/reset_password/"+@user.password_reset_code


                return;
            else
                flash[:alert] = "Could not find a user with that email address: #{params[:user][:login]}"
            end

        end
    end


    def forgot_password_result
    end


    # action to perform when the user resets the password
    def reset_password
        if request.post?
            logger.info("in users_controller reset_password reset code is "+params[:code])
            @user = User.find_by_password_reset_code(params[:code])
            return if @user unless params[:user]

            if ((params[:user][:password] == params[:user][:password_confirmation]))
                self.current_user = @user # for the next two lines to work

                logger.info("password_confirmation is "+params[:user][:password_confirmation])

                @user.password_confirmation = params[:user][:password_confirmation]
                @user.password = params[:user][:password]

                logger.info("about to reset")

                @user.reset_password

                logger.info("done reset")

                result = current_user.save

                redirect_to show_user_path
                flash[:notice] = result ? "Password reset successfully" : "Unable to reset password"

            else

                logger.info("password mismatch")
                flash[:alert] = "Password mismatch"
                @user = self.current_user
            end
        end

    end


    def unlink

        @cuser= current_user
        logger.info("current user is "+@cuser.login)
        @user= User.find(params[:id])

        @relationship = Relationship.find_by_owner_id_and_target_id(@cuser.id, @user.id)
        @relationship = Relationship.find_by_owner_id_and_target_id(@user.id, @cuser.id) unless @relationship

        if @relationship
            @relationship.destroy

            # destroying pending users
            #            if(@user.state = "pending")
            #                @user.destroy
            #            end
            #            render_component :controller=>"users",:action=>"show", :id=>@user2.id

            flash[:notice] = "Connection removed"

            redirect_to relationships_path
        end
    end

    def merge

        @user = self.current_user
        if request.put?
            @mergeTo = User.authenticate(params[:login], params[:password])

            logger.info("in merge to post")
            if @mergeTo==nil
                flash[:notice] = "Incorrect login or password"
                redirect_back_or_default('/merge')
            elsif @mergeTo == self.current_user
                flash[:notice] = "You cannot merge to the same account you are logged in to"
                redirect_back_or_default('/merge')
            else
                logger.info("in merge. Target is "+@mergeTo.name+" from is "+@user.name)
                # todo move relationships and delete user then forward to new user

                fromUsers = @user.connectedUsers
                toUsers = @mergeTo.connectedUsers

                fromUsers.each do |i|
                    logger.info("fromUsers contains "+i.name)
                end

                toUsers.each do |i|
                    logger.info("toUsers contains "+i.name)
                end

                fromUsers.each do |possible|

                    if possible.login == @mergeTo.login
                        logger.info("not adding myself to the list "+possible.name)
                    elsif toUsers.include?(possible)
                        # todo check this one
                        logger.info("found "+possible.name+" already in target connection list")
                    else
                        logger.info("adding new connection from "+@mergeTo.name+" to "+possible.name)



                        r = Relationship.find(:first, :conditions => { :owner_id => @user.id, :target_id => possible.id})
                        r = Relationship.find(:first, :conditions => { :target_id => @user.id, :owner_id => possible.id}) unless r

                        if r.owner_id == @user.id
                            logger.info("Owner "+@user.name)
                            r.owner = @mergeTo
                            r.target = possible

                        elsif r.target_id == @user.id
                            logger.info("Owner "+possible.name)
                            r.owner = possible
                            r.target = @mergeTo
                        else
                            logger.error("expected relationship not null")
                        end

                        r.save()

                    end
                end

                @mergeTo.save()

                # reload associations as they are cached
                @mergeTo.toConnections(true)
                @mergeTo.fromConnections(true)



                #move items to new profile
                @user.items.each do |item|
                    item.owner = @mergeTo
                    item.save
                end

                #reload association or the items will be deleted when user is deleted
                @user.items(true)
                @mergeTo.items(true)



                #delete all jumps from user to mergeTo and vice_versa
                @delete_jumps = Item.find_by_sql("select * from jumps where (from_user_id = #{@mergeTo.id} and to_user_id = #{@user.id}) or (to_user_id = #{@mergeTo.id} and from_user_id = #{@user.id})")

                @delete_jumps.each do |jump|
                    jump.destroy
                end


                #jumps to fromUser are redirected to toUser
                #but only if toUser has not been jumped with the same item


                #all items that have jumped to or from mergeTo user
                @item_jumps_to = Item.find_by_sql("select * from items where id in (select item_id from jumps where to_user_id = #{@mergeTo.id})")
                @item_jumps_from = Item.find_by_sql("select * from items where id in (select item_id from jumps where from_user_id = #{@mergeTo.id})")

                @user.jumps_to.each do |jump|
                    unless @item_jumps_to.include?(jump.item)
                        jump.to_user = @mergeTo
                        jump.save
                    end
                end


                @user.jumps_from.each do |jump|
                    unless @item_jumps_from.include?(jump.item)
                        jump.from_user = @mergeTo
                        jump.save
                    end
                end


                #reload associations or the jumps will be deleted when user is deleted
                @user.jumps_to(true)
                @mergeTo.jumps_to(true)
                @user.jumps_from(true)
                @mergeTo.jumps_from(true)


                # any communication between mergeTo and user is deleted
                @delete_replies = Reply.find_by_sql("select * from replies where (from_user_id = #{@mergeTo.id} and to_user_id = #{@user.id}) or (to_user_id = #{@mergeTo.id} and from_user_id = #{@user.id})")

                @delete_replies.each do |reply|
                    reply.destroy
                end

                @user.senders(true)
                @user.receivers(true)
                @mergeTo.senders(true)
                @mergeTo.receivers(true)


                # communication to user is moved to mergeTo
                @user.senders.each do |reply|
                    reply.to_user = @mergeTo
                    reply.save
                end

                # communication from user is moved to mergeTo
                @user.receivers.each do |reply|
                    reply.from_user = @mergeTo
                    reply.save
                end

                @user.senders(true)
                @user.receivers(true)
                @mergeTo.senders(true)
                @mergeTo.receivers(true)


                # move applications to mergeTo, but only if merge to has not already applied to the same item


                @user.destroy

                # todo: check how to reload association

                self.current_user = @mergeTo
                @user = self.current_user
                flash[:notice] = "Your connections have been merged. You are now logged in as "+@mergeTo.login

                redirect_to show_user_path

            end
        end

    end


    def add
        @user = User.find_by_login(params[:login])

        if @user and self.current_user.connectedUsers.include?(@user)
            flash[:notice] = "Your already have a connection to #{params[:login]}"
            redirect_to relationships_path
            return
        elsif @user
            logger.info("Allready got user with email "+@user.login)
            redirect_to :controller => "relationships", :action => "new", :login => @user.login
            return

        else
            logger.info("Not got user with email "+params[:login])
            redirect_to :action=>"new", :login=>params[:login]
            return

        end

        redirect_to("/")
        return

    end


    def index
        @user = self.current_user
        #render :action => "show"
        redirect_to(@user)
    end

    # GET /users/1/edit
    def edit
        @user = self.current_user
    end


    def update
        @user = self.current_user

        if params[:user][:login]
            flash[:alert] = 'Your IP has been logged'
            redirect_to("/logout")
            return
        end

        if @user.update_attributes(params[:user])
            flash[:notice] = 'Profile was successfully updated.'
            redirect_to(show_user_path)
        else
            render :action => "edit"
        end
    end


    def toggle_show_help
        @user = self.current_user
        if(@user.show_help)
            @user.show_help = false
        else
            @user.show_help = true
        end

        @user.save

        redirect_to request.env['HTTP_REFERER']
    end


    def accept_agreement

        @user = self.current_user

        if request.post?
            @user = self.current_user
            @user.accepted = true
            @user.accepted_at = Time.now.utc
            @user.save
            #redirect_to request.env['HTTP_REFERER']
            if session[:last_action]

                redirect_to session[:last_action]
                session[:last_action] = nil # need to do this or we are redirected back to login after agreement
            else
                redirect_to show_user_path
            end
        end

    end


    def decline_agreement

        self.current_user.delete!
        reset_session
        redirect_to "/"
        return

    end



    protected
    def find_user
        @user = User.find(params[:id])
    end

    def random_pronouncable_password(size = 4)
        c = %w(b c d f g h j k l m n p qu r s t v w x z ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr)
        v = %w(a e i o u y)
        f, r = true, ''
        (size * 2).times do
            r << (f ? c[rand * c.size] : v[rand * v.size])
            f = !f
        end
        r
    end


end
