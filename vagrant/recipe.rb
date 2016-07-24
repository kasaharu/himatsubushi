USER = 'vagrant'
HOME = "/home/#{USER}"
BASH_RC = "#{HOME}/.bashrc"


%w{vim git openssl}.each do |pkg|
  package pkg
end

# For Erlang
%w{gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel}.each do |pkg|
  package pkg
end

asdf_path = "#{HOME}/.asdf"

execute 'set asdf script' do
  command "
    echo '. #{asdf_path}/asdf.sh'               >> #{BASH_RC}
    echo '. #{asdf_path}/completions/asdf.bash' >> #{BASH_RC}
  "
  not_if "test -d #{asdf_path}"
end

git asdf_path do
  user USER
  repository "https://github.com/asdf-vm/asdf.git"
  action :sync
end


