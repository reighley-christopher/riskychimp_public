class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :client_id
      t.string :transaction_id
      t.float :amount
      t.datetime :transaction_date
      t.string :email
      t.string :name
      t.string :ip
      t.string :shipping_city
      t.string :shipping_state
      t.string :shipping_zip
      t.string :shipping_country
      t.string :purchaser_id
      t.text :other_data

      t.timestamps
    end
  end
end
