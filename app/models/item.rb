class Item < ActiveRecord::Base
    belongs_to :owner, :class_name => "User"


    has_many :jumps,
            :foreign_key => 'item_id',
            :class_name => 'Jump',
            :dependent => :destroy

    has_many :replies,
            :foreign_key => 'item_id',
            :class_name => 'Reply'


    def do_close
        self.state = 'closed'
        self.closed_at = Time.now.utc
    end


end
