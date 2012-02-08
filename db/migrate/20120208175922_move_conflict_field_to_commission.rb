class MoveConflictFieldToCommission < ActiveRecord::Migration
  def change
    add_column :commissions, :conflict, :boolean, :default => false
    add_index :commissions, :conflict

    #execute "update commissions set conflict=false"

    # if exist checked protocols
    #Protocol.find_all_by_conflict(true).each do |p|
    #  p.commission
    #end

    remove_column :protocols, :conflict
    #remove_index :protocols, :conflict


  end
end
