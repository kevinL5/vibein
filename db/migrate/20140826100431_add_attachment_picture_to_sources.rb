class AddAttachmentPictureToSources < ActiveRecord::Migration
  def self.up
    change_table :sources do |t|
      t.attachment :picture
    end
  end

  def self.down
    remove_attachment :sources, :picture
  end
end
