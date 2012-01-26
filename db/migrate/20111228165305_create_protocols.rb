class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.timestamps

      t.integer :commission_id      
    end
  end
end
