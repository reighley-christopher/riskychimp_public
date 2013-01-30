class AddUnparsedTransactionDatetimeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :unparsed_transaction_datetime, :string
    add_column :transactions, :transaction_datetime, :datetime
    add_column :transactions, :transaction_datetime_offset, :string
  end
end
