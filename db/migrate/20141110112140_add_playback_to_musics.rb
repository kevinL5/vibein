class AddPlaybackToMusics < ActiveRecord::Migration
  def change
    add_column :musics, :playback, :integer
  end
end
