require 'rubygems'
require "bundler/setup"
require 'rack/test'
require 'sinatra'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

require "#{File.dirname(__FILE__)}/../app.rb"

describe App do
  include Rack::Test::Methods
  
  def app
    @app ||= App
  end
  
  it "should render a welcome page" do
    get '/'
    last_response.body.should == "<html><body><h1>Sinatra has taken the stage.</h1></body></html>"
  end
end