class CreateUsers < ActiveRecord::Migration
    def self.up
        create_table "users", :force => true do |t|
            t.column :login,                     :string            
            t.column :crypted_password,          :string, :limit => 40
            t.column :salt,                      :string, :limit => 40
            t.column :created_at,                :datetime
            t.column :updated_at,                :datetime
            t.column :remember_token,            :string
            t.column :remember_token_expires_at, :datetime
            t.column :activation_code, :string, :limit => 40
            t.column :activated_at, :datetime
            t.column :state, :string, :null => :no, :default => 'passive'
            t.column :deleted_at, :datetime
            t.column :password_reset_code,       :string, :limit => 40
            t.column :is_admin,                  :boolean, :default => false
            t.string :name, :null=>false
            t.column :initiator_id, :int
            t.column :initiationMessage, :text
        end
    end

    def self.down
        drop_table "users"
    end
end
