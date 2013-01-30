class AddTimeZoneToUserSetting < ActiveRecord::Migration
  def change
    add_column :user_settings, :time_zone, :string
  end
end
