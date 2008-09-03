class RelationshipsController < ApplicationController


    skip_filter :login_required, :only => [:activate]


    def new
        @relationship = Relationship.new(params[:relationship])
        @user = User.find_by_login(params[:login])


    
    end


    def create

        unless simple_captcha_valid?
            flash[:notice] = "Wrong code. Please try again"
            redirect_to :action=>"new",:relationship => params[:relationship] ,:login => params[:login]
            return

        end

        @relationship = Relationship.new(params[:relationship])
        @target = User.find_by_login(params[:login])

        @relationship.owner = self.current_user
        @relationship.target = @target
        @relationship.state = "pending"
        @relationship.make_activation_code


        if @relationship.save
            @activation_url  = "#{SITE}/activate_relationship/#{@relationship.activation_code}"
            flash[:notice] = 'Relationship was successfully created.'
            UserMailer.deliver_relationship_notification(@relationship)
            redirect_to relationships_path
        else
            render :action => "new"
        end
    end


    def activate
        relationship = Relationship.find_by_activation_code(params[:activation_code])
        if (relationship==nil)
            logger.error("Expected relationship when activating relationship. Found none for activation code "+params[:activation_code])
        else
            relationship.state = 'active'
            relationship.save


            # if the user har not activated then activate here as they are activating a relationship link
            if !relationship.target.active?
                relationship.target.activate!
            end

            flash[:notice] = 'Relationship was successfully activated.'
            self.current_user = relationship.target
            redirect_to(relationship.target)
        end
    end


    def index
        @user = current_user
        @jumps = Jump.find_all_by_to_user_id(@user.id)

        @meconnected = Relationship.find_by_sql("select r.* from relationships r, users o ,users t where r.owner_id = o.id and r.target_id = t.id and o.id = #{@user.id} order by t.name")
        @theyconnected = Relationship.find_by_sql("select r.* from relationships r, users t, users o where r.target_id = t.id and r.owner_id = o.id and t.id = #{@user.id} order by o.name")
    end

end
