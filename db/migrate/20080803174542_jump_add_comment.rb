class JumpAddComment < ActiveRecord::Migration
  def self.up
      add_column :jumps, :comment, :text
  end

  def self.down
      remove_column :jumps, :comment
  end
end
