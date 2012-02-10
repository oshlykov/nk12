class AddSourceToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :source, :string
  end
end
