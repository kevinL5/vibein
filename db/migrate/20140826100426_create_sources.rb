class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.text :provider
      t.text :identification
      t.text :title
      t.text :uploader
      t.integer :duration
      t.datetime :uploaded

      t.timestamps
    end
  end
end
