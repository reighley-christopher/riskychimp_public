class AddStatusToTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :status, :string

    Transaction.reset_column_information
    Transaction.all.each do |transaction|
      transaction.update_attribute(:status, 'pending') if transaction.status.blank?
    end
  end

  def self.down
    remove_column :transactions, :status
  end
end
