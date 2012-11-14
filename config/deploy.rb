require "bundler/capistrano"
set :application, "std.ledez.net"

server "kick-ass", :app, :web, :db
set :deploy_to, "/var/www/ror/apps/std.ledez.net"
set :rails_env, :production
set :assets_env, "RAILS_GROUPS=assets"
set :root_url, "http://std.ledez.net"
set :repository, "git@github.com:organicweb/std2.git"
set :use_sudo, false
set :user, "ror"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :scm, :git

role :app, "kick-ass"

namespace :deploy do
  task :start, :roles => :app do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
  
  task :stop, :roles => :app do
    #nothing
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
  
  task :pipeline_precompile, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
  end
  
  task :bundleize, :roles => :app, :except => { :no_release => true } do
    run "cd #{release_path}; bundle"
  end
end

before "deploy:setup" do
  run "rm -rf /var/www/ror/apps/std.ledez.net/current"
end 

after "deploy" do
  deploy.bundleize
  run "cd #{current_path}; RAILS_ENV=production rake db:migrate"
  deploy.pipeline_precompile
  deploy.cleanup
end