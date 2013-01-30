class AddErrorInvitedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :error_invited, :boolean
  end
end
