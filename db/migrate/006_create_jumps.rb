class CreateJumps < ActiveRecord::Migration
    def self.up
        create_table :jumps do |t|

            t.column :item_id, :int, :null => false
            t.column :parent_id, :int
            t.column :from_user_id, :int, :null => false
            t.column :to_user_id, :int, :null => false
            t.column :jump_count, :int
            t.column :application, :text

            t.timestamps
        end
    end

    def self.down
        drop_table :jumps
    end
end
