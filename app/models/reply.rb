class Reply < ActiveRecord::Base
    belongs_to :item, :class_name => "Item"

    belongs_to :from_user, :class_name => "User"
    belongs_to :to_user, :class_name => "User"

    

end