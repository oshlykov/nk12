class CreateVotings < ActiveRecord::Migration
  def change
    create_table :votings do |t|
      t.integer :protocol_id
      t.integer :votes
      t.integer :voting_dictionary_id

      t.timestamps
    end
    add_index :votings, :protocol_id
    add_index :votings, :voting_dictionary_id
  end
end
