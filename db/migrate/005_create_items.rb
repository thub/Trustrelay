class CreateItems < ActiveRecord::Migration
    def self.up
        create_table :items do |t|
            t.column :description, :text
            t.column :owner_id, :int

            t.timestamps
        end
    end

    def self.down
        drop_table :items
    end
end
