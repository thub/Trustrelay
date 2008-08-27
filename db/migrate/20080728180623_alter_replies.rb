class AlterReplies < ActiveRecord::Migration
    def self.up
        add_column :replies, :item_id, :int, :null=>false
        add_column :replies, :from_user_id, :int, :null=>false
        add_column :replies, :to_user_id, :int, :null=>false

    end

    def self.down

        remove_column :replies, :item_id
        remove_column :replies, :from_user_id
        remove_column :replies, :to_user_id

    end
end
