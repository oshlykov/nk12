class AddCommissionIndexUrl < ActiveRecord::Migration
  def change
      add_index :commissions, :url, :unique => true
  end
end
