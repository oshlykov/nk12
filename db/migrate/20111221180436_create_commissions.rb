class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.string :name
      t.string :url

      t.timestamps

      t.string :ancestry
      t.boolean :is_uik, :default => 0
      t.integer :election_id
      t.boolean :uik_holder, :default => 0
      t.string :voting_table_url
      t.boolean :votes_taken
    end
    add_index :commissions, :ancestry
  end
end
