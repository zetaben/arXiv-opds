require 'rubygems'
require 'sinatra'
require 'arxiv'
require 'builder'
require 'open-uri'
require 'nokogiri'
require 'haml'

global_etag="v0"
AGENT="ArXiv-OPDS/0.1"

get '/' do
	haml :index
end

get '/catalog.atom' do
	etag global_etag+'catalog'
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.top.to_a,:arxiv => arxiv, :current_cat => 'root'}
end

get '/subcats/*.atom' do
	id=params[:splat].first
	etag global_etag+"subcats_#{id}"
	content_type 'application/atom+xml', :charset => 'utf-8'
	arxiv=ArXiv.new
	builder :nav_feed, :locals => { :cats => arxiv.subcats(id).to_a, :arxiv => arxiv, :current_cat => id}
end


get '/feed/*.atom' do 
	id=params[:splat].first
	etag global_etag+"feed_#{id}_#{params[:start]}_#{params[:max_results]}_#{Time.now.to_i/3600}"
	url="http://export.arxiv.org/api/query?search_query=cat:#{id}&sortBy=submittedDate&sortOrder=descending"
	url+="&max_results=20" unless params[:max_results]
	arxiv=ArXiv.new
	title=arxiv.name(id)
	current_path="/feed/#{id}.atom?"
	
	content_type 'application/atom+xml', :charset => 'utf-8'
	feed_to_opds(url,current_path,title,params).to_s
end

get '/opensearchdescription.xml' do 
	etag global_etag+"opensearch"
	content_type 'application/xml'
	builder :opensearch_description
end

get '/robots.txt' do 
	'User-agent: *'+"\n"+
	'Disallow: /search/'+"\n"+
	'Disallow: /feed/'+"\n"
end

get '/search/' do
	redirect('/catalog.atom') if params[:q].nil?
	etag global_etag+"search_#{params[:q]}_#{params[:start]}_#{params[:max_results]}_#{Time.now.to_i/3600}"
	url="http://export.arxiv.org/api/query?search_query=all:#{ params[:q]}"	
	title="Search results for query all:#{ params[:q]}"
	current_path="/search/?q=#{ params[:q]}"

	content_type 'application/atom+xml', :charset => 'utf-8'
	feed_to_opds(url,current_path,title,params).to_s
end

def feed_to_opds(url,current_path,title,params)
	url+="&start=#{params[:start]}" if params[:start]
	url+="&max_results=#{params[:max_results]}" if params[:max_results]
	feed=Nokogiri::XML(open(url,{"User-Agent" => AGENT}))
	arxiv=ArXiv.new

	namespaces=feed.namespaces.to_hash.merge({ 'xmlns:opensearch'=>"http://a9.com/-/spec/opensearch/1.1/","xmlns"=>"http://www.w3.org/2005/Atom"})
	total=feed.at('/xmlns:feed/opensearch:totalResults',namespaces).text.to_i
	start=feed.at('/xmlns:feed/opensearch:startIndex',namespaces).text.to_i
	perpage=feed.at('/xmlns:feed/opensearch:itemsPerPage',namespaces).text.to_i

	feed.at('/xmlns:feed/xmlns:title',namespaces).content = title
	feedel=feed.at('/xmlns:feed/xmlns:entry',namespaces)
	feedel=feed.at('/xmlns:feed/xmlns:id',namespaces) if feedel.nil?

	link=Nokogiri::XML::Node.new('link',feed)
	link['rel']='search'
	link['title']='Search Arxiv'
	link['href']='/search/?q={searchTerms}'
	link['type']='application/atom+xml'
	feedel.add_previous_sibling(link)
	link=Nokogiri::XML::Node.new('link',feed)
	link['rel']='search'
	link['title']='Search Arxiv'
	link['type']='application/opensearchdescription+xml'
	link['href']='/opensearchdescription.xml'
	feedel.add_previous_sibling(link)
	unless start+perpage > total
		link=Nokogiri::XML::Node.new('link',feed)
		link['rel']='next'
		link['title']='Next Page'
		link['href']="#{current_path}&start=#{(start+perpage)}"
		link['type']='application/atom+xml'
		feedel.add_previous_sibling(link)
	end
	unless start-perpage < 0
		link=Nokogiri::XML::Node.new('link',feed)
		link['rel']='prev'
		link['title']='Previous Page'
		link['href']="#{current_path}&start=#{(start-perpage)}"
		link['type']='application/atom+xml'
		feedel.add_previous_sibling(link)
	end

	feed.xpath('/xmlns:feed/xmlns:entry',namespaces).each do |ent|
		link=ent.at('./xmlns:link[@type="application/pdf"]',namespaces)
		acq_link=link.dup
		acq_link['rel']="http://opds-spec.org/acquisition/open-access"
		ent.add_child(acq_link)
		cats=[]
		ent.xpath('./xmlns:category',namespaces).each do |cat|
			cat['label']=arxiv.name(cat['term']) 
			cats.push cat['term']
			if cat['term']['.']
				cat2=cat.dup
				cat2['term']=cat2['term'].split('.').first
				cat2['label']=arxiv.name(cat2['term'])
				cat.add_previous_sibling(cat2)
				cat.add_previous_sibling(Nokogiri::XML::Text.new("\n",feed))
				cats.push cat2['term'].split('.').first
			end
		end

		cats.uniq.each do |cat_term|
		link=Nokogiri::XML::Node.new('link',feed)
		link['rel']='related'
		link['title']="More articles in #{arxiv.name(cat_term)}"
		link['href']="/feed/#{cat_term}.atom"
		link['type']='application/atom+xml'
		ent.add_child(link)
		ent.add_child(Nokogiri::XML::Text.new("\n",feed))

		end
	end
	feed
end


get '/subcats/' do redirect('/catalog.atom') end
get '/feed/' do redirect('/catalog.atom') end
