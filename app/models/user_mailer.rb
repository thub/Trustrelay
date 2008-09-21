class UserMailer < ActionMailer::Base


    def signup_notification(user)
        setup_email(user,'Please activate your new account')
        @body[:url]  = "#{SITE}/activate/#{user.activation_code}"
        @body[:about]  = "#{SITE}/about.html"        

    end

    def signup_notification_relationship(user)
        unless user.initiator==nil
            recipients  "#{user.login}"
            from        %{"Do not reply" <bounce@yourdomain.com>}
            subject     "[#{SITE}] #{user.initiator.name+' invites you to TrustRelay.com'}"
            sent_on     Time.now
            body        :user => user

            @body[:url]  = "#{SITE}/activate/#{user.activation_code}"
            @body[:about]  = "#{SITE}/about.html"
        end
    end

    def item_notification(jump,subj='A new job has been relayed to you')
        recipients  "#{jump.to_user.login}"
        from        %{"Do not reply" <bounce@yourdomain.com>}
        subject     "[#{SITE}] #{subj}"
        sent_on     Time.now
        body        :jump => jump

        @body[:url]  = "#{SITE}/items/#{jump.item.id}"
    end


     def feedback_notification(user,message)
         logger.info("message is "+message)
        recipients  "hubertz@online.no"
        from        %"#{user.login}"
        subject     "[#{SITE}] feedback"
        sent_on     Time.now
         @body[:message] = message
    end


    def app_notification(jump,subj='New application for '+jump.item.title)
        recipients  "#{jump.item.owner.login}"
        from        %{"Do not reply" <bounce@trustrelay.com>}
        subject     "[#{SITE}] #{subj}"
        sent_on     Time.now
        body        :jump => jump
        @body[:url]  = "#{SITE}/apps/#{jump.app.id}"
    end

#    def reply_notification_from_owner(reply,subj='More information regarding job opening '+reply.item.title)
#        recipients  "#{reply.to_user.login}"
#        from        %{"Do not reply" <bounce@trustrelay.com>}
#        subject     "[#{SITE}] #{subj}"
#        sent_on     Time.now
#        body        :reply => reply
#        @body[:url]  = "#{SITE}#{new_reply_path(reply.item)}"
#    end
#
#    def reply_notification_from_user(reply,subj='New request for information about job opening '+reply.item.title)
#        recipients  "#{reply.item.owner.login}"
#        from        %{"Do not reply" <bounce@trustrelay.com>}
#        subject     "[#{SITE}] #{subj}"
#        sent_on     Time.now
#        body        :reply => reply
#
#        @body[:url]  = "#{SITE}#{new_reply_owner_path(reply.item,reply.from_user)}"
#    end

      def reply_notification(reply,subj='Message regarding job opening '+reply.item.title)
        recipients  "#{reply.item.owner.login}"
        from        %{"Do not reply" <bounce@trustrelay.com>}
        subject     "[#{SITE}] #{subj}"
        sent_on     Time.now
        body        :reply => reply
        @body[:url]  = "#{SITE}#{new_reply_path(reply.item,reply.from_user)}"
    end



    def relationship_notification(relationship,subj='You have a new connection request')
        recipients  "#{relationship.target.login}"
        #from        %"#{relationship.owner.login}"
        from        %{"Do not reply" <bounce@trustrelay.com>}
        subject     "[#{SITE}] #{subj}"
        sent_on     Time.now
        body        :relationship => relationship
        @body[:url]  = "#{SITE}/activate_relationship/#{relationship.activation_code}"
    end


    def activation(user)
        setup_email(user,'Your account has been activated!')
        @body[:url]  = "#{SITE}/"
    end

    def forgot_password(user)

        setup_email(user,'You have requested to change your password')
        @body[:url]  = "#{SITE}/reset_password/#{user.password_reset_code}"

    end

    def reset_password(user)
        setup_email(user,'Your password has been reset.')
    end

    protected

    def setup_email(user,subj=nil)
        recipients  "#{user.login}"
        from        %{"Do not reply" <bounce@trustrelay.com>}
        subject     "[#{SITE}] #{subj}"
        sent_on     Time.now
        body        :user => user

    end
end