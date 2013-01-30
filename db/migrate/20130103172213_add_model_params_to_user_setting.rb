class AddModelParamsToUserSetting < ActiveRecord::Migration
  def change
    add_column :user_settings, :model_params, :text
  end
end
