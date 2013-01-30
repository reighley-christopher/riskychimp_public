class AddMoreIndexesToTransactions < ActiveRecord::Migration
  def change
    add_index :transactions, :ip
    add_index :transactions, [:client_id, :purchaser_id]
  end
end
