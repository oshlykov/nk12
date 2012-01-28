class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.integer :commission_id
      t.integer :user_id
      t.timestamps

    end
  end
end
