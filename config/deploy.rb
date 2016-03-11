#---------------------------------------------------------------------------------------------------------------------
# deploy Rail 4 avec capistrano V3
#---------------------------------------------------------------------------------------------------------------------
#
# first deploy :
# -------------
# install rvm :
# install ruby :
# install mysql :
# install passenger/nginx :

# Next deploy :
# -------------
# avant tout deploy, il faut publier sur https://devscrapper/statupweb.git avec la commande
# git push origin master
#
# pour deployer dans un terminal avec ruby 223 dans la path : cap production deploy
# cette commande prend en charge :
# la publication des sources vers le serveur cible
# les migration mysql
# la publication des fichiers de paramèrage : database.yml, secret.yml(n'est pas utilisé, car on lit la var d'enviroennemnt
# dans le fichier application.config.rb => la var est defini dans le fichier /etc/profile : EXPORT SECRET_KEY_BASE="la clé")
# les liens vers les repertoires partagés et le current vers les relaease
# le redemarrage de passenger
# le redemraage de delay_job (en production)
#---------------------------------------------------------------------------------------------------------------------

lock '3.4.0'

set :application, 'statupbot'
set :repo_url, "git@github.com://github.com/devscrapper/#{fetch(:application)}.git/"
set :repo_url, "https://github.com/devscrapper/#{fetch(:application)}.git/"
set :github_access_token, '64c0b7864a901bc6a9d7cd851ab5fb431196299e'
set :default, 'master'
set :user, 'eric'
set :pty, false
set :use_sudo, false
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

SSHKit::Backend::Netssh.configure do |ssh|
  ssh.ssh_options = {
      user: fetch(:user),
      auth_methods: ['publickey']
  }
end


#----------------------------------------------------------------------------------------------------------------------
# task list : log
#----------------------------------------------------------------------------------------------------------------------
namespace :log do
  task :down do
    host = SSHKit::Host.new(fetch(:server))
    # host.password = "Brembo01"
    host.user = fetch(:user)
    host.port = 22
    on host do  |host|
    ls_output = capture(:ls, '-l')
    p ls_output
  end

 end
end


namespace :deploy do
  task :bundle_install do
    on roles(:app) do
      within release_path do
        execute :bundle, "--gemfile Gemfile --path #{shared_path}/bundle  --binstubs #{shared_path}bin --without [:development]"
      end
    end
  end
  after 'deploy:updating', 'deploy:bundle_install'


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
