require "./app"
set :server, thin
run Sinatra::Application