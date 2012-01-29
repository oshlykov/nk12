class AddConflictToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :conflict, :boolean, :default => false
    add_index :protocols, :conflict
  end
end
