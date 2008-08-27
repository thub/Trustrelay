class App < ActiveRecord::Base
    belongs_to :jump , :class_name => "Jump"
end
