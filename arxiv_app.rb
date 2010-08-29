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

get '/search/' do
	redirect('/catalog.atom') if params[:q].nil?
	url="http://export.arxiv.org/api/query?search_query=all:#{ params[:q]}"
	burl=url.dup
	url+="&start=#{params[:start]}" if params[:start]
	url+="&max_results=#{params[:max_results]}" if params[:max_results]
	feed=Nokogiri::XML(open(url))
	
	namespaces=feed.namespaces.to_hash.merge({ 'xmlns:opensearch'=>"http://a9.com/-/spec/opensearch/1.1/","xmlns"=>"http://www.w3.org/2005/Atom"})
	STDERR.puts namespaces.inspect
	total=feed.at('/xmlns:feed/opensearch:totalResults',namespaces).text.to_i
	start=feed.at('/xmlns:feed/opensearch:startIndex',namespaces).text.to_i
	perpage=feed.at('/xmlns:feed/opensearch:itemsPerPage',namespaces).text.to_i

	feedel=feed.at('/xmlns:feed/xmlns:entry',namespaces)
	unless start+perpage > total
	link=Nokogiri::XML::Node.new('link',feed)
	link['rel']='next'
	link['title']='Next Page'
	link['href']="/search/?q=#{ params[:q]}&start=#{(start+perpage)}"
	feedel.add_previous_sibling(link)
	end
	unless start-perpage < 0
	link=Nokogiri::XML::Node.new('link',feed)
	link['rel']='prev'
	link['title']='Previous Page'
	link['href']="/search/?q=#{ params[:q]}&start=#{(start-perpage)}"
	feedel.add_previous_sibling(link)
	end

	feed.xpath('/xmlns:feed/xmlns:entry',namespaces).each do |ent|
		link=ent.at('./xmlns:link[@type="application/pdf"]',namespaces)
		acq_link=link.dup
		acq_link['rel']="http://opds-spec.org/acquisition/open-access"
		ent.add_child(acq_link)
		link=Nokogiri::XML::Node.new('link',feed)
		link['rel']='http://opds-spec.org/image/thumnail'
		link['title']='Icon'
		link['href']="http://www.gravatar.com/avatar/#{Digest::RMD160.hexdigest(acq_link['href'])}?d=identicon"
		ent.add_child(link)
	end
	content_type 'application/atom+xml', :charset => 'utf-8'
	feed.to_s
end


get '/subcats/' do redirect('/catalog.atom') end
get '/feed/' do redirect('/catalog.atom') end
