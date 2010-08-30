xml.instruct!(:xml, :encoding => "UTF-8")
xml.feed("xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom') do |feed|
	feed.title("#{current_cat=='root' ? 'Arxiv' : arxiv.name(current_cat) } subcategories")
	feed.id(request.url)
	feed.updated(Time.now.xmlschema)
	feed.link(:type => 'application/atom+xml',:href => request.url, :rel => 'self', :title => "Current Feed" )
	feed.link(:type => 'application/atom+xml',:href => '/catalog.atom', :rel => 'start', :title => "Root catalog" )
	feed.link(:type => 'application/atom+xml', :href => "/subcats/#{current_cat.split('.').first}.atom", :rel => 'up', :title => "#{arxiv.name(current_cat.split('.').first)} subsections")	if current_cat['.']
	feed.link(:type => 'application/opensearchdescription+xml', :href => '/opensearchdescription.xml', :rel => 'search', :title => 'Search ArXiv')
	feed.link(:type => 'application/atom+xml', :href => '/search/?q={searchTerms}', :rel => 'search', :title => 'Search ArXiv')
	feed.author do |author|
		author.name "Benoit Larroque"
		author.uri "http://github.com/zetaben"
	end

	cats.each do |cat_name,id|
	feed.entry do |entry|
		entry.title cat_name
		if arxiv.subcat?(id) && id!=current_cat
		 entry.id  "/subcats/#{id}.atom"
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} subcategories", :href => "/subcats/#{id}.atom")
		 entry.link(:type => 'application/atom+xml', :title => "#{cat_name} subcategories", :href => "/subcats/#{id}.atom") #preopds
		else
		 entry.id  "/feed/#{id}.atom"
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} articles", :href => "/feed/#{id}.atom")
		 entry.link(:type => 'application/atom+xml', :title => "#{cat_name} articles", :href => "/feed/#{id}.atom") #preopds
		end
		entry.category(:label => cat_name, :term => id )
		entry.link(:type => 'text/html',:href => "http://arxiv.org/list/#{id}/recent", :rel => 'alternate',  :title => "#{cat_name} html listing" )
		entry.updated(Time.now.xmlschema)
	end
	end

end
 
