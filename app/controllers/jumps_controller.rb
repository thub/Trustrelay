class JumpsController < ApplicationController

    def add_application
        @user = self.current_user
        @jump = Jump.find_by_to_user_id_and_item_id(@user.id, params[:id])

        @jump.interest = true
        @jump.application = params[:jump][:application]
        @jump.save

        redirect_to @jump.item
    end



end
