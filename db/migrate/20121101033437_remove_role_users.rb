class RemoveRoleUsers < ActiveRecord::Migration
  def up
    drop_table :roles_users
  end

  def down
    create_table :roles_users, :id => false do |t|
      t.integer :user_id
      t.integer :role_id
    end
  end
end
