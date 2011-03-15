include_recipe "joy_of_cooking::daemontools"

src_dir = "/usr/local/src/mysql"
install_dir = "/usr/local/mysql"

{
  "cmake" => "2.6.4-5.el5.2",
  "bison" => "2.3-2.1",
  "ncurses-devel" => "5.5-24.20060715"
}.each do |package_name, version_string|
  package package_name do
    action :install
    version version_string
  end
end

user "mysql"

group "mysql" do
  members ['mysql']
end

run_unless_marker_file_exists("mysql_5_5_9") do
  execute "download mysql src" do
    command "mkdir -p #{src_dir} && curl -Lsf http://mysql.he.net/Downloads/MySQL-5.5/mysql-5.5.9.tar.gz |  tar xvz -C#{src_dir} --strip 1"
  end

  execute "cmake" do
    command "cmake ."
    cwd src_dir
  end

  execute "make" do
    command "make install"
    cwd src_dir
  end
  
  execute "mysql owns #{install_dir}/data" do
    command "chown -R mysql #{install_dir}/data"
  end

  execute "install db" do
    command "#{install_dir}/scripts/mysql_install_db --user=mysql"
    cwd install_dir
  end
end 

execute "create daemontools directory" do
  command "mkdir -p /service/mysql"
end

execute "create run script" do
  command "echo -e '#!/bin/sh\nexec /command/setuidgid mysql  /usr/local/mysql/bin/mysqld' > /service/mysql/run"
  not_if "ls /service/mysql/run"
end

execute "make run script executable" do
  command "chmod 755 /service/mysql/run"
end