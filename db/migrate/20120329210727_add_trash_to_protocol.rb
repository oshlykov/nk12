class AddTrashToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :trash, :boolean, :null => false, :default => false

    add_index :protocols, :trash
  end
end
