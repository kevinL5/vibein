class Category < ActiveRecord::Base
  belongs_to :user

  has_many :categorizations, dependent: :destroy

  has_many :musics,
    through: :categorizations
end
