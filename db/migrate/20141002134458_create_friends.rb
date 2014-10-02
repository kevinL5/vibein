class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.text :friend_uid
      t.references :user, index: true

      t.timestamps
    end
  end
end
