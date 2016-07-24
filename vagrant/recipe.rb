USER = 'vagrant'
HOME = "/home/#{USER}"
BASH_RC = "#{HOME}/.bashrc"


%w{vim git}.each do |pkg|
  package pkg
end

# For Erlang
%w{gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel autoconf java-1.8.0-openjdk-devel}.each do |pkg|
  package pkg
end
# For Elixir
package 'unzip'

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
    not_if "test `#{validate_asdf} asdf plugin-list | grep #{lang[:name]} | wc -l` -eq 1"
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
