class Jump < ActiveRecord::Base



    belongs_to :parent, :class_name => "Jump"
    belongs_to :item, :class_name => "Item"

    belongs_to :from_user, :class_name => "User"
    belongs_to :to_user, :class_name => "User"

    has_one :app, :class_name => "App",:foreign_key=>"jump_id"
  
    has_many :children,
            :foreign_key => 'parent_id',
            :class_name => 'Jump'


    


end
