class AddShowHelp < ActiveRecord::Migration
  def self.up
      add_column :users, :show_help, :boolean, :default=>true
  end

  def self.down
      remove_column :users, :show_help
  end

end
