class Music < ActiveRecord::Base
  belongs_to :user
  belongs_to :source

  has_many :categorizations, dependent: :destroy

  has_many :categories, through: :categorizations
end
