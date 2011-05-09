include_recipe "joy_of_cooking::daemontools"
include_recipe "joy_of_cooking::xvfb"
include_recipe "joy_of_cooking::git_config"

username = ENV['SUDO_USER'].strip
user_home = ENV['HOME']

install_dir = "/usr/local/jenkins"
bin_location = "#{install_dir}/jenkins.war"
jenkins_dir = "/home/mkocher/.jenkins"

execute "download jenkins" do
  command "mkdir -p #{install_dir} && curl -Lsf http://mirrors.jenkins-ci.org/war/latest/jenkins.war -o #{bin_location}"
  not_if { File.exists?(bin_location) }
end

execute "download git plugin" do
  command "mkdir -p #{jenkins_dir}/plugins && curl -Lsf http://mirrors.jenkins-ci.org/plugins/git/latest/git.hpi -o #{jenkins_dir}/plugins/git.hpi"
  not_if { File.exists?("#{jenkins_dir}/plugins/git.hpi") }
  user username
end

execute "make projec#t dir" do
  command "mkdir -p #{jenkins_dir}/jobs/cimonitor"
  user username
end

template "#{jenkins_dir}/jobs/cimonitor/config.xml" do
  source "jenkins-cimonitor-config.xml.erb"
  owner username
end

service_name = "jenkins"

execute "create daemontools directory" do
  command "mkdir -p /service/#{service_name}"
end

execute "create run script2" do # srsly! the not_if from mysql was being applied because they had the same name. I kid you not.
  command "echo -e '#!/bin/sh\nexport PATH=/usr/local/mysql/bin/:$PATH\nexport HOME=/home/mkocher\nexec /command/setuidgid mkocher  /usr/bin/java -jar #{bin_location}' > /service/#{service_name}/run"
  # not_if "ls /service/#{service_name}/run"
end

execute "make run script executable" do
  command "chmod 755 /service/#{service_name}/run"
end