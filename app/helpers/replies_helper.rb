module RepliesHelper

     def reply_help(owner)
        return '<div id="help">
            * This message will be sent to '+owner.name+' (the initiator of this job opportunity) while you will remain anonymous,<br/>
              but feel free include your contact information if you wish to continue the dialog outside this system
        </div>' unless self.current_user.show_help==false
    end
end
