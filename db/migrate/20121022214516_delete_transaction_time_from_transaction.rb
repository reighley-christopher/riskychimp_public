class DeleteTransactionTimeFromTransaction < ActiveRecord::Migration
  def up
    remove_column :transactions, :transaction_time
  end

  def down
    add_column :transactions, :transaction_time, :time
  end
end
