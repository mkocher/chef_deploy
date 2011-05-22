#!/bin/bash -e
export app_user="mkocher"

# perl -e 'print crypt("password", "salt"),"\n"'
getent passwd $app_user >/dev/null 2>&1 || useradd $app_user -p sa3tHJ3/KuYvI

# copy root's authorized keys to app_user
mkdir -p  /home/$app_user/.ssh
touch /home/$app_user/.ssh/authorized_keys
chmod 700 /home/$app_user/.ssh
chmod 600 /home/$app_user/.ssh/authorized_keys
chown -R $app_user /home/$app_user/.ssh

authorized_keys_string=`cat /root/.ssh/authorized_keys`
grep -sq "$authorized_keys_string" /home/$app_user/.ssh/authorized_keys || cat /root/.ssh/authorized_keys >> /home/$app_user/.ssh/authorized_keys


## enable ssh password auth
perl -p -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config 
/etc/init.d/sshd reload

# install epel
rpm -q epel-release-5-4.noarch || rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

# install git
yum -y install git

# rvm prereqs
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel iconv-devel java

# passwordless sudo
sudo_string='ALL            ALL = (ALL) NOPASSWD: ALL'
grep "$sudo_string" /etc/sudoers || echo "$sudo_string" >> /etc/sudoers

cat <<'BOOTSTRAP_AS_USER' > /home/$app_user/bootstrap_as_user.sh
set -e

mkdir -p /home/$app_user/rvm/src
curl -Lsf http://github.com/wayneeseguin/rvm/tarball/156d0b42feba4922ad04 | tar xvz -C/home/$app_user/rvm/src --strip 1
cd "/home/$app_user/rvm/src" && ./install

rvm_include_string='[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
grep "$rvm_include_string" ~/.bashrc || echo "$rvm_include_string" >> ~/.bashrc

cat <<'RVMRC_CONTENTS' > ~/.rvmrc
rvm_install_on_use_flag=1
rvm_trust_rvmrcs_flag=1
rvm_gemset_create_on_use_flag=1
RVMRC_CONTENTS
BOOTSTRAP_AS_USER

chmod a+x /home/$app_user/bootstrap_as_user.sh
su - $app_user /home/$app_user/bootstrap_as_user.sh
rm /home/$app_user/bootstrap_as_user.sh