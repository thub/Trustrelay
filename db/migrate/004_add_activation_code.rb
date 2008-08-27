class AddActivationCode < ActiveRecord::Migration
  def self.up
      add_column :relationships, :activation_code, :text, :limit => 40
  end

  def self.down
      remove_column :relationships, :activation_code
  end

end
