class Category < ActiveRecord::Base
  belongs_to :user

  has_many :categorizations

  has_many :musics,
    through: :categorizations
end
