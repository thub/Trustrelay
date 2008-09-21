class RepliesController < ApplicationController



    def list_for_owner
        logger.info("in index")
        @user = self.current_user

        @for_user = User.find(params[:user_id])
        @item = Item.find(params[:item_id])


        unless @item.owner == self.current_user
            logger.info("hack attemt ") # todo, log IP
            flash[:alert] = 'You do not have access to this reply'
            redirect_to("/")
            return
        end


        @replies = Reply.find(:all,:conditions=>['item_id = ? and (to_user_id = ? or from_user_id = ?) and (to_user_id = ? or from_user_id = ?) ',
                @item.id,
                @user.id,
                @user.id,
                @for_user.id,
                @for_user.id],:order=>"created_at desc")

        render :action=>"new"
    end

    def list_for_user
        logger.info("in list for user")
        @user = self.current_user
        @item = Item.find(:item_id)


        unless @item.owner == self.current_user
            logger.info("hack attemt ") # todo, log IP
            flash[:alert] = 'You do not have access to this reply'
            redirect_to("/")
            return
        end


        @replies = Reply.find(:all,:conditions=>['item_id = ? and (to_user_id = ? or from_user_id = ?)',
                @item.id,
                @user.id,
                @user.id],:order=>"created_at desc")
    end



    # GET /Replies/new
    def new
        @reply = Reply.new
        @item = Item.find(params[:item_id])
        @user = self.current_user
        @owner = @item.owner


        unless @owner == self.current_user
            unless self.current_user.transient_items.include?(@item)
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this reply'
                redirect_to("/")
                return
            end
        end

        @to_user
        @from_user

        if @owner == @user
            @to_user = User.find(params[:to_id])
            @from_user = @user


        elsif params[:to_id]


            @to_user = User.find(params[:to_id])
            @from_user = @user

            unless are_connected @to_user,@from_user
                flash[:alert] = 'You are not connected to this user'
                redirect_to("/")
                return
            end

        else

            @show_help == true
            @to_user = @item.owner
            @from_user = @user

        end


        @replies = Reply.find(:all,:conditions=>['item_id = ? and (to_user_id = ? or from_user_id = ?) and (to_user_id = ? or from_user_id = ?) ',
                @item.id,
                @user.id,
                @user.id,
                @to_user.id,
                @to_user.id],:order=>"created_at ")


    end


    def are_connected(from_user,to_user)
        Relationship.find(:all,:conditions=>['(owner_id = ? or target_id = ?) and (owner_id = ? or target_id = ?) ',
                from_user,
                from_user,
                to_user,
                to_user])

    end


    # POST /Replies
    def create

        logger.debug("in create")
        @reply = Reply.new(params[:reply])





        unless @reply.item.owner == self.current_user
            unless self.current_user.transient_items.include?(@reply.item)
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this reply'
                redirect_to("/")
                return
            end
        end

        if @reply.save

            to =  nil

            UserMailer.deliver_reply_notification(@reply)
                           to  = @reply.item.owner
                           redirect_to new_reply_path(@reply.item,@reply.to_user)



            flash[:notice] = 'Reply was registered. Notification email was sent to '+@reply.to_user.name



            return
        else
            render :action => "new"
        end
    end


end