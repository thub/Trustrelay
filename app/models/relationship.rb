class Relationship < ActiveRecord::Base

    belongs_to :owner, :class_name => "User"
    belongs_to :target, :class_name => "User"

#    def orderId
#        return :owner.id
#    end

     def make_activation_code
        if(self.activation_code == nil)
            self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
            logger.info("in make_activation_code code "+self.activation_code)
        else
            logger.info("in make_activation_code code keeping  "+self.activation_code)
        end
    end

end
