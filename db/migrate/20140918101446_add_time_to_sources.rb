class AddTimeToSources < ActiveRecord::Migration
  def change
    add_column :sources, :time, :text
  end
end
