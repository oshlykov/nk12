class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.string :name
      t.string :url

      t.timestamps

      t.text :voting_labels
    end
  end
end
