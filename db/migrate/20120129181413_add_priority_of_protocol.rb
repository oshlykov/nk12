class AddPriorityOfProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :priority, :integer, :default => 100
    add_index :protocols, :priority
  end
end
