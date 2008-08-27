class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|

        t.column :jump_id, :int
        t.column :description, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
end
