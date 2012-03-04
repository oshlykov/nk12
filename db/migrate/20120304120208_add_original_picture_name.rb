class AddOriginalPictureName < ActiveRecord::Migration
  def change
    add_column :pictures, :original_filename, :string
  end
end
