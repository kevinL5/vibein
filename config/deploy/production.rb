# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
role :app, %w{54.171.240.238}
role :web, %w{54.171.240.238}
role :db,  %w{54.171.240.238}

set :stage, :production
set :keep_releases, 1
# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
server '54.171.240.238', user: 'deploy', roles: %w{web app}, password: 'Qkflgkrtod'
