class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.integer :commission_id, :created_by_id, :null => false
      t.string :comment, :null => false, :default => ''
      t.integer :user_id
      t.datetime :reserved_at

      t.timestamps
    end

    add_index :folders, :commission_id
    add_index :folders, :user_id
    add_index :folders, :reserved_at
  end
end
