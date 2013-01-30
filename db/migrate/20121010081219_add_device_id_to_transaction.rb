class AddDeviceIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :device_id, :string
  end
end
