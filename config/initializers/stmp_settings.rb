if File.exist?("#{Rails.root}/config/smtp.yml")
  SMTP_SETTING = YAML.load(ERB.new(File.read("#{Rails.root}/config/smtp.yml")).result)[Rails.env]
else
  SMTP_SETTING = {
    "user_name" => ENV["smtp_user_name"],
    "password" => ENV["smtp_password"]
  }
end

ActionMailer::Base.smtp_settings = {
  :user_name => SMTP_SETTING["user_name"],
  :password => SMTP_SETTING["password"],
  :domain => "gmail.com",
  :address => "smtp.gmail.com",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
