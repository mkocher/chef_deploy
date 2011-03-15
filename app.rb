require 'rubygems'
require "bundler/setup"
require 'sinatra'

class App < Sinatra::Base
  get '/' do
    "<html><body><h1>Sinatra has taken the stage.</h1></body></html>"
  end
end