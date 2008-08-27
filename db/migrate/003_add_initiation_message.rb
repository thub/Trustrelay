class AddInitiationMessage < ActiveRecord::Migration
  def self.up
      add_column :relationships, :initiationMessage, :text
  end

  def self.down
      remove_column :relationships, :initiationMessagge
  end

end
