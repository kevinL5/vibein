class Source < ActiveRecord::Base

  has_attached_file :picture,
    styles: { medium: "100x100^>", thumb: "100x100>" }

  validates_attachment_content_type :picture,
    content_type: /\Aimage\/.*\z/

end
