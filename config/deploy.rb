# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "novelty"
set :repo_url, 'git@github.com:github_user_name/github_repository_name.git'
# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :format is :airbrussh.
# set :format, :airbrussh

set :puma_threads,    [4, 16]
set :puma_workers,    0
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :rbenv_type, :system
set :keep_releases, 5
# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  'config/master.key',
)
# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads'
)
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_path, '/usr/local/rbenv'
set :log_level, :debug
# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'reload the database with seed data'
  task :seed do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rails, 'db:seed'
        end
      end
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
end
