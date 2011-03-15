require 'capistrano/ext/multistage'

$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ruby-1.8.7-p299@testgemset'        # Or whatever env you want it to run in.
set :rvm_type, :user

set :app_name, :foo
set(:app_dir) { "/var/#{stage}/#{app_name}" }
set :user, "mkocher"
default_run_options[:pty] = true 

desc "Deploys"
task :deploy do
  install_base_gems
  upload_cookbooks
  run_chef
end

desc "Install gems that are needed for a chef run"
task :install_base_gems do
  run "gem list | grep soloist || gem install soloist --no-rdoc --no-ri"
  # run "gem list | grep hellspawn || gem install hellspawn --no-rdoc --no-ri"
end

desc "Upload cookbooks"
task :upload_cookbooks do
  run "sudo mkdir -p #{app_dir}"
  run "sudo chown -R #{user} #{app_dir}"
  run "rm #{app_dir}/soloistrc || true"
  run "rm -r #{app_dir}/chef || true"
  upload("soloistrc", "#{app_dir}/soloistrc")
  upload("chef/", "#{app_dir}/chef/", :via => :scp, :recursive => true)
end

desc "Run Chef"
task :run_chef do
  run "cd #{app_dir} && PATH=/usr/sbin:$PATH soloist"
end

desc "bootstrap"
task :bootstrap do
  set :user, "root"
  set :default_shell, "/bin/bash"
  upload "bootstrap.sh", "/root/bootstrap.sh"
  run "chmod a+x /root/bootstrap.sh"
  run "/root/bootstrap.sh"
end