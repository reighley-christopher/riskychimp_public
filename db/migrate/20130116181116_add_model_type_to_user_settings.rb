class AddModelTypeToUserSettings < ActiveRecord::Migration
  def change
    add_column :user_settings, :model_type, :string
  end
  def down
    remove_column :user_settings, :model_type
  end
end
