# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require 'bundler/setup'

redis_opts = {url: ENV['REDIS_URL']}

if (password = ENV['REDIS_PASSWORD'])
  redis_opts[:password] = password
end

set :redis, Redis.new(redis_opts)

get '/' do
  'OK'
end

get '/ping' do
  settings.redis.ping.to_s
end

get '/inc' do
  settings.redis.incr('counter').to_s
end

get '/counter' do
  settings.redis.get('counter').to_s
end

get '/version' do
  ENV['HOSTNAME']
end
