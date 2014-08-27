class CreateMusics < ActiveRecord::Migration
  def change
    create_table :musics do |t|
      t.boolean :favorite
      t.references :user, index: true
      t.references :source, index: true

      t.timestamps
    end
  end
end
