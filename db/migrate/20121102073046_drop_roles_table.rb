class DropRolesTable < ActiveRecord::Migration
  def up
    drop_table :roles
    remove_index :users, :role_id
    remove_column :users, :role_id
    add_column :users, :role, :string
  end

  def down
    remove_column :users, :role
    add_column :users, :role_id, :integer
    add_index :users, :role_id
    create_table :roles do |t|
      t.string :title
    end
  end
end
