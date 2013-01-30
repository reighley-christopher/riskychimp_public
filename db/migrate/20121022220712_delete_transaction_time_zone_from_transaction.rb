class DeleteTransactionTimeZoneFromTransaction < ActiveRecord::Migration
  def up
    remove_column :transactions, :transaction_time_zone
  end

  def down
    add_column :transactions, :transaction_time_zone, :string
  end
end
