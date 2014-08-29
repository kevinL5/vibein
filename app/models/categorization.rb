class Categorization < ActiveRecord::Base
  belongs_to :music
  belongs_to :category
end
