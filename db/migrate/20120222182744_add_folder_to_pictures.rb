class AddFolderToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :folder_id, :integer

    add_index :pictures, :folder_id
  end
end
