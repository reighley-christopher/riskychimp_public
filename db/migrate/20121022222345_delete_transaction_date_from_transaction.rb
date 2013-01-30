class DeleteTransactionDateFromTransaction < ActiveRecord::Migration
  def up
    remove_column :transactions, :transaction_date
  end

  def down
    add_column :transactions, :transaction_date, :datetime
  end
end
