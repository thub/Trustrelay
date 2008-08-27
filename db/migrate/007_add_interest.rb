class AddInterest < ActiveRecord::Migration
  def self.up
      add_column :jumps, :interest, :boolean, :default=>false
  end

  def self.down
      remove_column :jumps, :interest
  end

end
