class Music < ActiveRecord::Base
  belongs_to :user
  belongs_to :source
end
