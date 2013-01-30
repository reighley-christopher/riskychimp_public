Riskybiz Project
http://www.riskychimp.com


How to setup the project?
```
bundle
rake db:drop db:create db:migrate
rake db:seed
```
Notice:
```
Login with admin role:
user: admin@riskybiz.com
password: secret
In config/initializers/constants.rb: please provide your access_key and secret access key
In config/initializers/secret_token.rb: please provide your own app secret token
Make sure you have the following items installed:
 + firefox
 + chrome and relevant selenium chrome driver
 + adobe flash 11.5.502.146 or newer
```

