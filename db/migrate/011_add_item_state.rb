class AddItemState < ActiveRecord::Migration
  def self.up
     add_column :items, :state, :string , :default=>'open'
     add_column :items, :closed_at, :datetime
  end

  def self.down
      remove_column :items, :state
      remove_column :items, :closed_at
  end

end
