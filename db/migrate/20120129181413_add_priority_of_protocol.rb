class AddPriorityOfProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :priority, :integer
    add_index :protocols, :priority
  end
end
