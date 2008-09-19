module UsersHelper

    def help
        if self.current_user.show_help
            return link to "hide help", toggle_help_path
        else
            return link to "show help", toggle_help_path
        end
    end


    def email_help
            return '
        <div id="help">
            <p>
                *If you wish to change your email address :<br/>
                1. add a connection with your new email address <br/>
                2. activate that connection                     <br/>
                3. log in with the email address you want to move away from<br/>
                4. then merge your account using your new email address <br/>
                Your connections and jobs will be moved to the new account
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false

    end

     def help_help
            return '
        <div id="help">
            <p>
                *You can toggle help messages on or off by clicking Show/Hide help above
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false

    end


    def name_help
        return '
        <div id="help">
            <p>
                *Full name is not neccessary. Our policy is to collect minimal information about you
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false
    end



    def description_help_edit
        return '
        <div id="help">
            <p>
                *In case you signal interest in a job opportunity this information may be relayed to the job initiator.<br/>
                The job initiator will contact you for further details so you do not have to include everything here
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false

    end


    def description_help_new
        return '
        <div id="help">
            <p>
                *In case an user signals interest in a job opportunity this information may be relayed to the job initiator.<br/>
                The job initiator will contact you for further details so you do not have to include everything here
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false

    end


     def initiation_help
        return '
        <div id="help">
            <p>
                *An email with activation link  will be sendt to your new connnection. The message you enter here will acompany this email
            </p>
        </div>' unless self.current_user==nil or self.current_user.show_help==false

    end
end