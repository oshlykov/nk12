class AddCommissionIndexToProtocol < ActiveRecord::Migration
  def change
    add_index :protocols, :commission_id
  end
end
