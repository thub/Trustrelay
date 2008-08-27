class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.column :owner_id, :int
      t.column :target_id, :int
      t.column :state, :string, :default => 'pending', :null=>false     

      t.timestamps
    end
  end

  def self.down
    drop_table :relationships
  end
end
