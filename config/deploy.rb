set :application, "riskybiz"

set :scm, :git
set :repository, "git@github.com:EastAgile/riskybiz.git"
role :app, "ec2-67-202-19-169.compute-1.amazonaws.com"
role :web, "ec2-67-202-19-169.compute-1.amazonaws.com"

set :bundle_roles, [:app]
require 'bundler/capistrano'
set :user, "ubuntu"
set :branch, "master"
set :deploy_to, "/home/ubuntu/Projects/riskybiz/"
set :shared_dir, "shared"
ssh_options[:user] = "ubuntu"
ssh_options[:keys] = ["~/.ssh/ea_staging.pem"]
set :use_sudo, false
set :normalize_asset_timestamps, false
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "ln -s #{shared_path}/config/mail_config.yml #{current_path}/config/mail_config.yml"
    run "touch #{shared_path}/log/production.log"
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
