xml.instruct!(:xml, :encoding => "UTF-8")
xml.feed("xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom','xmlns:dc' => 'http://purl.org/dc/elements/1.1/') do |feed|
	feed.title(rdf_feed.at('/rdf:RDF/xmlns:channel/xmlns:title',rdf_feed.namespaces).text)
	feed.id(request.url)
	updated=rdf_feed.at('/rdf:RDF/xmlns:channel/dc:date',rdf_feed.namespaces).text
	feed.updated(updated)
	rdf_feed.xpath('/rdf:RDF/xmlns:channel/dc:*',rdf_feed.namespaces).each do |dc|
		feed.tag!("dc:#{dc.name}",dc.text)
	end
	feed.link(:type => 'application/atom+xml',:href => request.url, :rel => 'self', :title => "Current Feed" )

	rdf_feed.xpath('/rdf:RDF/xmlns:item',rdf_feed.namespaces).each do |rdf_entry|
		feed.entry do |entry|
			entry.title(rdf_entry.at('./xmlns:title').text)
			id=rdf_entry.at('./xmlns:link').text
			entry.id(id)
			entry.updated(updated)
			entry.summary({:type => 'html'}, rdf_entry.at('./xmlns:description').text)
			creators=rdf_entry.at('./dc:creator').text
			Nokogiri::XML("<creators>#{creators}</creators>").xpath("//a").each do |a|
				entry.author do |author|
					author.name(a.text)
					author.uri(a.attributes['href'])
				end
			end
			entry.link(:type => 'application/pdf',:href => id.gsub('/abs/','/pdf/'), :rel => 'http://opds-spec.org/acquisition' , :title => "Download PDF")
			entry.link(:type => 'application/postscript',:href => id.gsub('/abs/','/pdf/'), :rel => 'http://opds-spec.org/acquisition', :title => "Download PS" )
			entry.link(:type => 'text/html',:href => id, :rel => 'alternate' )
				entry.category(:label => current_cat.split('.').first, :term => current_cat.split('.').first)	if current_cat['.']
				entry.category(:label => current_cat, :term => current_cat)	
				entry.link(:type => 'application/atom+xml', :href => "/subcats/#{current_cat.split('.').first}", :rel => 'subsection', :title => "#{current_cat.split('.').first} subsections")	if current_cat['.']
			
		end
	end


end
