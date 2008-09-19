module AppsHelper

    def app_desc_help
            return '<div id="help">
                    The text you write above goes back to the initiator of this job opportunity.<br/>
                    After you click submit a notification is sendt by email to the initiator of this job.<br/>
                    We will disclose your email address to the initiator of this job, but feel free to include other contact information in the text above.<br/>
                    You may choose to be brief or detailed about your experiences that makes you a good match for this job.<br/>
                    The initiator of this job opportunity may or may not contact you about your application.<br/>
                    You can at any point delete your application.<br/>

                  </div>' unless self.current_user.show_help==false
        end

end
