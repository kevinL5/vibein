class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.text :title
      t.text :thumbnail
      t.references :user, index: true

      t.timestamps
    end
  end
end
