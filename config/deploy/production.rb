set :deploy_to, deploysecret(:deploy_to)
set :server_name, deploysecret(:server_name)
set :db_server, deploysecret(:db_server)
set :branch, :stable
set :ssh_options, port: deploysecret(:ssh_port)
set :stage, :production
set :rails_env, :production
set :keep_releases, 5

#server deploysecret(:server1), user: deploysecret(:user), roles: %w(web app db importer cron background)
server deploysecret(:server2), user: deploysecret(:user), roles: %w(web app db importer cron background)
server deploysecret(:server3), user: deploysecret(:user), roles: %w(web app db importer)
server deploysecret(:server4), user: deploysecret(:user), roles: %w(web app db importer)
