class CreateReplies < ActiveRecord::Migration
  def self.up
       create_table :replies do |t|

         
            t.column :msg, :text

            t.timestamps
        end

  end

  def self.down
      drop_table :replies      
  end
end
