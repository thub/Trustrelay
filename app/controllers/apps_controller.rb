class AppsController < ApplicationController

    # GET /apps/1

    # display only to user that has applied and to initiator of item
    def show

        #check for initiator
        @app = App.find(params[:id])
        unless @app.jump.item.owner == self.current_user
            unless @app.jump.to_user == self.current_user
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this application'
                redirect_to("/")
                return
            end
        end


    end

    # GET /apps/new
    def new
        @app = App.new
        @jump = Jump.find(params[:jump_id])
    end

    # GET /apps/1/edit
    def edit
        @app = App.find(params[:id])
    end

    # POST /apps
    def create
        @app = App.new(params[:app])

         unless @app.jump.item.owner == self.current_user
            unless @app.jump.to_user == self.current_user
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this application'
                redirect_to("/")
                return
            end
        end

        if @app.save
            flash[:notice] = 'Application was successfully registered.'

             UserMailer.deliver_app_notification(@app.jump)

            redirect_to(@app)
        else
            render :action => "new"
        end
    end

    # PUT /apps/1
    def update
        @app = App.find(params[:id])

         unless @app.jump.item.owner == self.current_user
            unless @app.jump.to_user == self.current_user
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this application'
                redirect_to("/")
                return
            end
        end

        if @app.update_attributes(params[:app])
            flash[:notice] = 'app was successfully updated.'
            redirect_to(@app)
        else
            render :action => "edit"
        end
    end

    # DELETE /apps/1
    def destroy
        @app = App.find(params[:id])
            unless @app.jump.to_user == self.current_user
                logger.info("hack attemt ") # todo, log IP
                flash[:alert] = 'You do not have access to this application'
                redirect_to("/")
                return
         end
        @item = @app.jump.item
        @app.destroy
        flash[:notice] = 'Your application was successfully deleted'
        redirect_to(@item)
    end
end