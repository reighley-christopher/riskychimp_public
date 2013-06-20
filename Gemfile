source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'devise', '2.1.2' #2.2.0 broke User.invite! signature
gem 'haml-rails'
gem 'fog'
gem 'carrierwave'
gem 'state_machine'
gem 'devise_invitable'
gem 'paper_trail'
gem 'opengraph_parser', '>= 0.1.3'
gem 'exception_notification'
gem 'capistrano'
gem 'newrelic_rpm'
gem 'data_chimp', :path => 'vendor/gems/data_chimp'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'bourbon'
  gem 'jquery-ui-rails'
  gem 'jquery-rails'
  gem 'bourbon'
end

group :test, :development do
  gem "rspec-rails"
  gem 'debugger'
  gem 'awesome_print'
  gem 'zeus', require: false
  gem "factory_girl_rails"
  gem "faker"
end

group :test do
  gem 'cucumber-rails', :require => false
  gem "shoulda-matchers"
  gem "capybara", '1.1.2' # 2.0 breaks wait_until
  gem 'selenium-webdriver'
  gem "database_cleaner"
  gem "spork-rails"
end

git 'git://github.com/resolve/refinerycms.git', :branch => '2-0-stable' do
  gem 'refinerycms-core' #You can leave this out if you like. It's a dependency of the other engines.
  gem 'refinerycms-dashboard'
  gem 'refinerycms-images'
  gem 'refinerycms-pages'
  gem 'refinerycms-resources'
end

gem 'geoip', '1.1.2'
gem 'tzinfo', '0.3.33'
gem 'libsvm-ruby-swig'
gem 'ai4r'
gem 'countries'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
