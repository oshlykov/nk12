class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      #t.database_authenticatable :null => false
      #t.recoverable
      #t.rememberable
      #t.trackable
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :role, :default => 'guest'


      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.timestamps

    end

    add_index :users, :email, :unique => true
    add_index :users, :password_digest, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

end
