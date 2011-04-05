# execute "make src directory" do
#   dir_name = "#{ENV["APP_DIR"]}"
#   command "mkdir -p #{dir_name}"
#   not_if { File.exists?(dir_name) }
# end
# 

include_recipe "joy_of_cooking::daemontools"

app_user = "mkocher"

execute "trust github" do
  command "mkdir -p ~/.ssh/ && echo 'github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==' > ~/.ssh/known_hosts"
  user app_user
end

execute "user owns app dir" do
  command "chown -R #{app_user} #{ENV['APP_DIR']}"
end

execute "git clone" do
  command "git clone git://github.com/mkocher/chef_deploy.git src"
  cwd ENV['APP_DIR']
  not_if { File.exists?("#{ENV['APP_DIR']}/src/.git/")}
  user app_user
end

execute "checkout HEAD" do
  command "git reset HEAD --hard && git pull"
  cwd "#{ENV['APP_DIR']}/src"
  user app_user
end

execute "bundle" do
  command "bundle"
  user app_user
  cwd "#{ENV['APP_DIR']}/src"
end


execute "create daemontools directory" do
  command "mkdir -p /service/appserver"
end

file "/service/appserver/run" do
  content %{#!/bin/bash
cd /var/staging/foo/src
rvm_path=/home/mkocher/.rvm/
source /home/mkocher/.rvm/scripts/rvm
rvm use ruby-1.8.7-p299@captest
exec /command/setuidgid mkocher rackup -p 4567
}
  mode "0755"
  # not_if "ls /service/appserver/run"
end