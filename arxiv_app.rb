require 'rubygems'
require 'sinatra'
require 'arxiv'
require 'builder'
require 'open-uri'
require 'nokogiri'

get '/' do
	  "Hello from Sinatra on Heroku!"
end

get '/catalog.atom' do
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.top.to_a,:arxiv => arxiv, :current_cat => 'root'}
end

get '/subcats/*.atom' do
	id=params[:splat].first
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.subcats(id).to_a, :arxiv => arxiv, :current_cat => id}
end


get '/feed/*.atom' do 
	id=params[:splat].first
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	rdf_feed=Nokogiri::XML(open(arxiv.url(id)))
	builder :acq_rdf_feed, :locals => {:rdf_feed => rdf_feed, :current_cat => id}
end

get '/opensearchdescription.xml' do 
	content_type 'application/xml'
	builder :opensearch_description
end


get '/subcats/' do redirect('/catalog.atom') end
get '/feed/' do redirect('/catalog.atom') end
