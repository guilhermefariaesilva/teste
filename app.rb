# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'redis'
require 'bundler/setup'

set :redis, Redis.new(url: ENV['REDIS_URL'])

get '/' do
  'OK'
end

get '/inc' do
  settings.redis.incr('counter').to_s
end

get '/version' do
  ENV['HOSTNAME']
end
