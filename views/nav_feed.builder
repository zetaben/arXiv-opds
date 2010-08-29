xml.instruct!(:xml, :encoding => "UTF-8")
xml.feed("xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom') do |feed|
	feed.title("#{current_cat=='root' ? 'Arxiv' : current_cat } subcategories")
	feed.id(request.url)
	feed.updated(Time.now.xmlschema)
	feed.link(:type => 'application/atom+xml',:href => request.url, :rel => 'self', :title => "Current Feed" )
	feed.link(:type => 'application/atom+xml',:href => '/catalog.atom', :rel => 'start', :title => "Root catalog" )
	feed.link(:type => 'application/atom+xml', :href => "/subcats/#{current_cat.split('.').first}", :rel => 'up', :title => "#{current_cat.split('.').first} subsections")	if current_cat['.']
	cats.each do |cat_name,id|
	feed.entry do |entry|
		entry.title cat_name
		if arxiv.subcat?(id) && id!=current_cat
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} subcategories", :href => "/subcats/#{id}.atom")
		else
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} articles", :href => "/feed/#{id}.atom")
		end
		entry.link(:type => 'text/html',:href => "http://arxiv.org/list/#{id}/recent", :rel => 'alternate',  :title => "#{cat_name} html listing" )
		entry.link(:type => 'image/png', :href => "http://www.gravatar.com/avatar/#{Digest::RMD160.hexdigest(id)}?d=identicon", :rel => "http://opds-spec.org/image/thumbnail" )
		entry.updated(Time.now.xmlschema)
	end
	end

end
 
