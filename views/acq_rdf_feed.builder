xml.instruct!(:xml, :encoding => "UTF-8")
xml.feed("xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom','xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do |feed|
	feed.title(rdf_feed.at('/rdf:RDF/xmlns:channel/xmlns:title',rdf_feed.namespaces).text)
	feed.id(request.url)
	feed.icon(rdf_feed.at('/rdf:RDF/xmlns:image/xmlns:url',rdf_feed.namespaces).text)
	updated=rdf_feed.at('/rdf:RDF/xmlns:channel/dc:date',rdf_feed.namespaces).text
	feed.updated(updated)
	rdf_feed.xpath('/rdf:RDF/xmlns:channel/dc:*',rdf_feed.namespaces).each do |dc|
		feed.tag!("dc:#{dc.name}",dc.text)
	end
	feed.link(:type => 'application/atom+xml',:href => request.url, :rel => 'self', :title => "Current Feed" )
	feed.link(:type => 'application/atom+xml',:href => '/catalog.atom', :rel => 'start', :title => "Root catalog" )
	feed.link(:type => 'application/atom+xml', :href => "/subcats/#{current_cat.split('.').first}.atom", :rel => 'up', :title => "#{current_cat.split('.').first} subsections")	if current_cat['.']

	feed.link(:type => 'application/opensearchdescription+xml', :href => '/opensearchdescription.xml', :rel => 'search', :title => 'Search ArXiv')
	feed.link(:type => 'application/atom+xml', :href => '/search/?q={searchTerms}', :rel => 'search', :title => 'Search ArXiv')

	rdf_feed.xpath('/rdf:RDF/xmlns:item',rdf_feed.namespaces).each do |rdf_entry|
		feed.entry do |entry|
			entry.title(rdf_entry.at('./xmlns:title').text)
			id=rdf_entry.at('./xmlns:link').text
			entry.id(id)
			entry.updated(updated)
			entry.content({:type => 'text/html'}, rdf_entry.at('./xmlns:description').text)
			creators=rdf_entry.at('./dc:creator').text
			auth=[]
			Nokogiri::XML("<creators>#{creators}</creators>").xpath("//a").each do |a|
				entry.author do |author|
					author.name(a.text)
					author.uri(a.attributes['href'])
					auth.push [a.text,a.attributes['href']]
				end
			end
			entry.category(:label => current_cat.split('.').first, :term => current_cat.split('.').first)	if current_cat['.']
			entry.category(:label => current_cat, :term => current_cat)	
			entry.link(:type => 'application/pdf',:href => id.gsub('/abs/','/pdf/'), :rel => 'http://opds-spec.org/acquisition/open-access' , :title => "Download PDF")
			entry.link(:type => 'application/pdf',:href => id.gsub('/abs/','/pdf/'), :rel => 'http://opds-spec.org/acquisition' , :title => "Download PDF (preOPDS)") #preopds
			entry.link(:type => 'application/postscript',:href => id.gsub('/abs/','/ps/'), :rel => 'http://opds-spec.org/acquisition/open-access', :title => "Download PS" )
			entry.link(:type => 'text/html',:href => id, :rel => 'alternate' )
			entry.link(:type => 'application/atom+xml', :href => "/subcats/#{current_cat.split('.').first}.atom", :rel => 'subsection', :title => "#{current_cat.split('.').first} subsections")	if current_cat['.']

		end
	end


end
