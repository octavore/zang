require 'sinatra'

get '/' do
  erb(:index)
end

get '/elephant' do
  erb(:elephant)
end