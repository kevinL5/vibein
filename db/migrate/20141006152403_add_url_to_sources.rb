class AddUrlToSources < ActiveRecord::Migration
  def change
    add_column :sources, :url, :text
  end
end
