class AppSetting < ActiveRecord::Base
  attr_accessible :key, :value
  SENDER = "send out email as"
end
