class AddCommissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :commission_id, :integer
  end
end
