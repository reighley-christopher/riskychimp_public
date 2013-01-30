class AddIndexesToTransactions < ActiveRecord::Migration
  def change
    add_index :transactions, :client_id
    add_index :transactions, :purchaser_id
    add_index :transactions, :device_id
  end
end
