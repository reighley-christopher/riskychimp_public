class AddConfirmableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token,   :unique => true

    User.reset_column_information
    User.all.each do |user|
      user.confirmed_at = user.confirmation_sent_at = Time.now
      user.save
    end
  end
end
