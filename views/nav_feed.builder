xml.instruct!(:xml, :encoding => "UTF-8")
xml.feed("xml:lang" => "en-US", "xmlns" => 'http://www.w3.org/2005/Atom') do |feed|
	cats.each do |cat_name,id|
	feed.entry do |entry|
		entry.title cat_name
		if arxiv.subcat?(id) && id!=current_cat
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} subcategories", :href => "/subcats/#{id}.atom")
		else
		 entry.link(:rel => 'subsection', :type => 'application/atom+xml', :title => "#{cat_name} articles", :href => "/feed/#{id}.atom")
		end
	end
	end

end
 
