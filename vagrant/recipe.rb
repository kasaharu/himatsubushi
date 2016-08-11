USER = 'vagrant'
HOME = "/home/#{USER}"
BASH_RC = "#{HOME}/.bashrc"
USER_BIN_DIR = '/usr/local/bin'


%w{vim git}.each do |pkg|
  package pkg
end

# For Erlang
%w{gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel}.each do |pkg|
  package pkg
end
# For Elixir
package 'unzip'

# For Phoenix
execute 'install inotify' do
  user 'root'
  url    = 'http://github.com/downloads/rvoicilas/inotify-tools/inotify-tools-3.14.tar.gz'
  file   = 'inotify-tools'
  output = "#{file}.tar.gz"
  command "
    curl -L #{url} -o #{output}
    tar xzf #{output}
    cd #{file}
    ./configure && make && make install
    cd ..
    rm -f #{file}*
  "
  not_if "test -f #{USER_BIN_DIR}/inotifywait -a #{USER_BIN_DIR}/inotifywatch"
end


asdf_path     = "#{HOME}/.asdf"
validate_asdf = "source #{asdf_path}/asdf.sh; source #{asdf_path}/completions/asdf.bash;"

execute 'set asdf script' do
  command "
    echo '#{validate_asdf}' >> #{BASH_RC}
  "
  not_if "test -d #{asdf_path}"
end

git asdf_path do
  user USER
  repository "https://github.com/asdf-vm/asdf.git"
  action :sync
end

langs = [
  {name: 'erlang', version: '19.0' , repo: 'https://github.com/asdf-vm/asdf-erlang.git'},
  {name: 'elixir', version: '1.3.2', repo: 'https://github.com/asdf-vm/asdf-elixir'    },
  {name: 'nodejs', version: '6.3.1', repo: 'https://github.com/asdf-vm/asdf-nodejs'    },
]
langs.each do |lang|
  execute "install #{lang[:name]} by asdf" do
    user USER
    command "
      #{validate_asdf}
      asdf plugin-add #{lang[:name]} #{lang[:repo   ]}
      asdf install    #{lang[:name]} #{lang[:version]}
      asdf global     #{lang[:name]} #{lang[:version]}
    "
    only_if "test `#{validate_asdf} asdf plugin-list | grep #{lang[:name]} | wc -l` -eq 0"
  end
end

# Setting vim
dein_dir_path = "#{HOME}/.vim/dein/repos/github.com/Shougo/dein.vim"
directory dein_dir_path do
  user USER
end

git dein_dir_path do
  user USER
  repository "https://github.com/Shougo/dein.vim.git"
  action :sync
end

remote_file "#{HOME}/.vimrc" do
  user USER
  source "cookbooks/vim/files/home/.vimrc"
end

# Setting bash
bashrc_ext = "#{HOME}/.bashrc_ext"
remote_file bashrc_ext do
  user USER
  source "cookbooks/bash/files/home/.bashrc_ext"
end

execute 'read bashrc_ext' do
  read_bash_ext = "source #{bashrc_ext}"
  command "
    echo '#{read_bash_ext}' >> #{BASH_RC}
  "
  only_if "test `grep '#{read_bash_ext}' #{BASH_RC} | wc -l` -eq 0"
end

# Install Phoenix
execute 'mix local.hex' do
  command "
    #{validate_asdf}
    mix local.hex --force
    mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force
  "
end
