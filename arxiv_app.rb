require 'rubygems'
require 'sinatra'
require 'arxiv'
require 'builder'

get '/' do
	  "Hello from Sinatra on Heroku!"
end

get '/catalog.atom' do
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.top.to_a,:arxiv => arxiv}
end

get '/subcats/*.atom' do
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.subcats(params[:splat].first).to_a,:arxiv => arxiv}
end
