class AddTransactionTimeAndTransactionTimeZoneToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_time, :time
    add_column :transactions, :transaction_time_zone, :string
  end
end
