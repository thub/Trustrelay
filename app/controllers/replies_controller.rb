class RepliesController < ApplicationController



    def list_for_owner
        logger.info("in index")
        @user = self.current_user

        @for_user = User.find(params[:user_id])
        @item = Item.find(params[:item_id])


        unless @item.owner == self.current_user
            logger.info("hack attemt ") # todo, log IP
            flash[:notice] = 'You do not have access to this reply'
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
            flash[:notice] = 'You do not have access to this reply'
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
                flash[:notice] = 'You do not have access to this reply'
                redirect_to("/")
                return
            end
        end


        if @owner == @user
            @owner_replies = true
            # look for userId of the user to send message to
            @to_user = User.find(params[:user_id])
            @from_user = @user

            @replies = Reply.find(:all,:conditions=>['item_id = ? and (to_user_id = ? or from_user_id = ?) and (to_user_id = ? or from_user_id = ?) ',
                    @item.id,
                    @user.id,
                    @user.id,
                    @to_user.id,
                    @to_user.id],:order=>"created_at ")


        else
            @to_user = @item.owner
            @from_user = @user

            @replies = Reply.find(:all,:conditions=>['item_id = ? and (to_user_id = ? or from_user_id = ?)',
                    @item.id,
                    @user.id,
                    @user.id],:order=>"created_at ")
        end




    end


    # POST /Replies
    def create

        logger.debug("in create")
        @reply = Reply.new(params[:reply])



        unless @reply.item.owner == self.current_user
            unless self.current_user.transient_items.include?(@reply.item)
                logger.info("hack attemt ") # todo, log IP
                flash[:notice] = 'You do not have access to this reply'
                redirect_to("/")
                return
            end
        end


        # who do we send reply notification to ?




        if @reply.save

            to =  nil

            if @reply.item.owner == self.current_user
                UserMailer.deliver_reply_notification_from_owner(@reply)
                to = @reply.to_user
                redirect_to new_reply_owner_path(@reply.item,@reply.to_user)

            else
                UserMailer.deliver_reply_notification_from_user(@reply)
                to  = @reply.item.owner
                redirect_to new_reply_path(@reply.item)

            end


            flash[:notice] = 'Reply was registered. Notification email was sent to '+to.name



            return
        else
            render :action => "new"
        end
    end


end