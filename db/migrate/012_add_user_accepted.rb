class AddUserAccepted < ActiveRecord::Migration
  def self.up
      add_column :users, :accepted, :boolean, :default=>false
      add_column :users, :accepted_at, :datetime
  end

  def self.down
      remove_column :users, :accepted
      remove_column :users, :accepted_at
  end

end
