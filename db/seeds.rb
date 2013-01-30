# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Added by Refinery CMS Pages extension
# Refinery::Pages::Engine.load_seed

puts "Populate location data started at #{Time.now}"
Util::ZipDatabase.instance.populate_zip_location
puts "Populate location data finished at #{Time.now}"

YAML.load(File.open("db/articles.yml")).each do |attr|
  Article.create(attr)
end
YAML.load(File.open("db/pages.yml")).each do |attr|
  Refinery::Page.create(attr)
end

def admin_user
  admin = User.new(email: "admin@riskybiz.com", password: "secret", password_confirmation: "secret")
  admin.confirmed_at =  Time.now
  admin.add_role("admin")
  admin.save
end
admin_user
