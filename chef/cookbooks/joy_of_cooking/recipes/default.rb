# install daemontools
# install mysql
# set up unicorn in daemontools

include_recipe "joy_of_cooking::mysql"

execute "Say Hello" do
  command "echo 'its very dark' > /help_im_stuck_in_the_machine"
end
