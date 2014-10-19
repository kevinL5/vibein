class Source < ActiveRecord::Base

  has_many :musics
  has_many :users,
    through: :musics

  has_attached_file :picture,
    styles: { medium: "100x100^>", thumb: "70^x70>" }

  validates_attachment_content_type :picture,
    content_type: /\Aimage\/.*\z/
end
