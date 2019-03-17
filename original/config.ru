require 'bundler'
require 'dotenv'
Bundler.require

require './app'

run Sinatra::Application
