class ItemsController < ApplicationController

    # GET /items
    def index
        logger.info("in index")
        @user = self.current_user
        @jumps = Jump.find_all_by_to_user_id(@user.id,:order=>"created_at desc")
    end

    # GET /items/1
    def show
        logger.info("in show")
        @item = Item.find(params[:id])
        @user = self.current_user

        #if this is a a jump to item for me then show interest button
        @jump = Jump.find_by_item_id_and_to_user_id(@item.id, @user.id)


        if not @jump and not @user.items.include?(@item)
            flash[:alert] = 'You do not have access to this job'
            redirect_to show_user_path
            return
        end

        @ijumps = Jump.find_all_by_item_id(@item.id,:conditions=>" id in ( select jump_id from apps)")
        logger.info("number of interested #{@ijumps.size}")


        #@ireplies = Reply.find(:all,:conditions=>"item_id = ? @item.id,:select=>"distinct item_id")

        @users_replied = User.find(:all,
                :conditions=>['id in (select from_user_id from replies where to_user_id = ? and item_id = ?)
                    or id in (select to_user_id from replies where from_user_id = ? and item_id = ?)',
                        self.current_user.id,
                        @item.id,
                        self.current_user.id,
                        @item.id])


    end

    # GET /items/new
    def new
        @item = Item.new
    end

    # GET /items/1/edit
    def edit
        @item = Item.find_by_id_and_owner_id(params[:id],self.current_user.id)

        if @item==nil
            logger.info("peeping ")
            flash[:alert] = 'No peeping !'
            reditect_to(self.current_user)
            return
        end

    end

    # POST /items
    def create
        @item = Item.new(params[:item])
        @item.owner = self.current_user

        if @item.save
            flash[:notice] = 'Job was successfully created.'
            redirect_to forward_item_path(@item)
        else
            render :action => "new"
        end
    end

    # PUT /items/1
    def update
        @item = Item.find_by_id_and_owner_id(params[:id],self.current_user.id)


            if @item.update_attributes(params[:item])
                flash[:notice] = 'Job was successfully updated.'
                 redirect_to(@item)
            else
                render :action => "edit"
            end

    end

    # DELETE /items/1
    def destroy
        @item = Item.find_by_id_and_owner_id(params[:id],self.current_user.id)
        @item.destroy
        flash[:notice] = 'Job was deleted.'

        redirect_to items_path
    end

    def forward


        @user = self.current_user
        @item = Item.find_by_id_and_owner_id(params[:id], self.current_user.id)
        @jump = Jump.find_by_to_user_id_and_item_id(@user.id, params[:id])
        @item = @jump.item unless @item

        @comment = params[:comment]
        unless @comment==nil
            logger.info("Comments "+@comment)
        end
        



        @sendt_to = User.find_by_sql("select * from users where id in (select to_user_id from jumps where item_id = #{@item.id} and from_user_id = #{@user.id})")

        @possible_recipients = User.find_by_sql("select * from users where (id in (select owner_id from relationships where target_id = #{@user.id})
or id in (select target_id from relationships where owner_id = #{@user.id}))
and id not in (select owner_id from items where id = #{@item.id}) and id not in (select to_user_id from jumps where item_id = #{@item.id})")


        if request.get?
            logger.info("in get")

            @pending_users = User.find_by_sql("select * from users where (id in (select owner_id from relationships where state='pending' and target_id = #{@user.id})
            or id in (select target_id from relationships where state='pending' and owner_id = #{@user.id}))")

            @meconnected = Relationship.find_by_sql("select r.* from relationships r, users o ,users t where r.owner_id = o.id and r.target_id = t.id and o.id = #{@user.id} order by t.name")
            @theyconnected = Relationship.find_by_sql("select r.* from relationships r, users t, users o where r.target_id = t.id and r.owner_id = o.id and t.id = #{@user.id} order by o.name")

        else
            @users = params[:users]

            unless @users!=nil
                redirect_to forward_item_path(@item)
                return
            end
            
            logger.info("in post with users ")
            for user_id in @users
                to_user = User.find(user_id)


                if @possible_recipients.include?(to_user)
                    logger.info("user to forward to "+to_user.name)

                    @njump = Jump.new
                    @njump.from_user = @user
                    @njump.to_user = to_user
                    @njump.item = @item
                    @njump.comment = @comment

                    if @jump
                        @njump.parent = @jump
                    end

                    @njump.save

                    UserMailer.deliver_item_notification(@njump)

                else
                    logger.info("user not in possible recipients"+to_user.name)
                end

            end

            flash[:notice] = 'Job was successfully relayed.'
            redirect_to forward_item_path(@item)
        end
    end

    
    def close
        @user = self.current_user
        @item = Item.find_by_id_and_owner_id(params[:id], self.current_user.id)

        @item.do_close
        @item.save

        redirect_to @item

    end

    def open
        @user = self.current_user
        @item = Item.find_by_id_and_owner_id(params[:id], self.current_user.id)

        @item.state = 'open'
        @item.save

        redirect_to @item

    end



end